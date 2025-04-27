extends GameObject

@export var move_speed: float = 100.0
@export var arrival_threshold: float = 1.0 # Smaller threshold for precise center alignment
@export var path: PackedVector2Array
@export var view_dir: Vector2
@export var move_points: int = 4 #number of move points per turn

var target_position: Vector2
var is_moving: bool = false
var _dog_eating_positions_defined: bool = false
var _dog_eating_positions:= [Vector2i(0,0),Vector2i(0,0)]
#ai position
var original_position: Vector2i#(0,0)
var original_positions = []

@onready var layer0: TileMapLayer = $"../../Layer0"
@onready var game_object_handler: GameObjectHandler = $"../"
@onready var _dog_eating_position_obj1: GameObject = $"../DogEatingPosition1"
@onready var _dog_eating_position_obj2: GameObject = $"../DogEatingPosition2"
@onready var _dog_bowl: GameObject = $"../DogBowl"

func get_dog_eating_positions() -> Array:
	if not(_dog_eating_positions_defined):
		_dog_eating_positions_defined = true
		_dog_eating_positions = [game_object_handler.tile_of_object(_dog_eating_position_obj1), game_object_handler.tile_of_object(_dog_eating_position_obj2)]
	return _dog_eating_positions

func is_bowl_non_empty() -> bool:
	return _dog_bowl.is_non_empty()

func path_to_eating_position(eating_position: Vector2i) -> PackedVector2Array:
	return MovementUtils.get_path_to_tile(
		layer0.local_to_map(global_position), #my_pos
		eating_position,
		layer0,
		get_parent().occupied_tiles_but_objs([self])
	)


func play(tour_nb) -> void:
	if tour_nb == 0: #first turn, save your oriignal position
		original_position = layer0.local_to_map(global_position)
		original_positions = [original_position,original_position+Vector2i(-1,0),original_position+Vector2i(0,1)]
		print("[Dog] MY POSITIONS",original_positions)
	var goal_position: Vector2i
	if is_bowl_non_empty():
		print("[Dog] Free Food :)")
		var potential_goal_positions: Array = get_dog_eating_positions()
		if game_object_handler.tile_of_object(self) in potential_goal_positions:
			print("[Dog] I'm eating, nomnom!")
			return
		for potential_goal_position in get_dog_eating_positions():
			var path = path_to_eating_position(potential_goal_position)
			if not path.is_empty():
				goal_position = potential_goal_position
				print("[Dog] Going to eat at ", goal_position)
				break
	else:
		print("[Dog] Expensive Food :(")
		goal_position = original_position
		var my_pos = layer0.local_to_map(global_position)
		for p in original_positions:
			if my_pos == p or not game_object_handler.occupied_tiles().has(p):
				goal_position = p
				break
		
	var new_path = MovementUtils.get_path_to_tile(
		layer0.local_to_map(global_position), #my_pos
		goal_position,
		layer0,
		get_parent().occupied_tiles_but_objs([self])
	)
	use_new_path(new_path.slice(0,move_points))
	return
	
func is_done() -> bool:
	return not is_moving
		
func _ready() -> void:
	# Snap initial position to tile center
	var current_tile = layer0.local_to_map(global_position)
	global_position = layer0.map_to_local(current_tile)
	#print("Player initial position (snapped to center): ", global_position)
	#var cylic_path: PackedVector2Array
	#cyclic_path = []
	#cyclic_path.append(Vector2(2,2))
	#cyclic_path.append(Vector2(2,-2))
	#cyclic_path.append(Vector2(-4,-2))
	#cyclic_path.append(Vector2(-4,2))
	#new_parameterized_path(cyclic_path,true)
	
#func new_parameterized_path(list_of_points, is_cyclic=false):
#	var new_path = []
#	var start_pos = list_of_points[0]
#	for i in range(1,list_of_points.size()):
#		var new_pos = list_of_points[i]
#		var new_path2 = MovementUtils.get_path_to_tile(
#				start_pos,
#				new_pos,
#				layer0,
#				layer1.get_used_cells()
#			)
#		new_path.append_array(new_path2)
#		start_pos = new_pos
#	if is_cyclic:
#		var new_path2 = MovementUtils.get_path_to_tile(
#				list_of_points[-1],
#				list_of_points[0],
#				layer0,
#				layer1.get_used_cells()
#			)
#		new_path.append_array(new_path2)
#	
#	use_new_path(new_path)
	
func use_new_path(new_path) -> void:
	if not new_path.is_empty():
		path = new_path
		is_moving = true
		target_position = path[0]
		#print("Path acceptpathed, first target: ", target_position)
		# Validate that target is different from current position
		if target_position.distance_to(global_position) < arrival_threshold:
			#print("Warning: First target too close to current position!")
			_advance_to_next_target()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			var click_pos = get_global_mouse_position()
			#print("\nNew movement requested")
			#print("From: ", global_position)
			#print("To: ", click_pos)
			
			# Convert world positions to tile coordinates
			var start_tile = layer0.local_to_map(global_position)
			var end_tile = layer0.local_to_map(click_pos)
			
			var new_path = MovementUtils.get_path_to_tile(
				start_tile,
				end_tile,
				layer0,
				get_parent().occupied_tiles_but_objs([self])
			)
			
			use_new_path(new_path)

func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if not is_moving or path.is_empty():
		if original_positions.has(layer0.local_to_map(global_position)):
			view_dir = Vector2(-1,0)
		return
		
	var distance_to_target = global_position.distance_to(target_position)
	#print("Distance to target: ", distance_to_target)
	
	if distance_to_target < arrival_threshold:
		# Snap to exact center when close enough
		global_position = target_position
		_advance_to_next_target()
	else:
		var direction = (target_position - global_position).normalized()
		
		var displacement = layer0.local_to_map(target_position) - layer0.local_to_map(global_position)
		if displacement.length() > 0.01:
			view_dir = Vector2(displacement).normalized()
		
		var movement = direction * move_speed * delta
		# Prevent overshooting by clamping movement to remaining distance
		if movement.length() > distance_to_target:
			movement = direction * distance_to_target
		global_position += movement
		#print("Moving: dir=", direction, " movement=", movement, " new_pos=", global_position)
	
	# true iff has seen player
	#if check_visibility():
	#	print("[Dog] Player seen")

func add_to_path(pos) -> void:
	path.append(pos)

func _advance_to_next_target() -> void:
	var pos = path[0]
	path.remove_at(0)
		
	#print("Point reached, remaining points: ", path.size())
	
	if path.is_empty():
		#print("Path completed")
		is_moving = false
		return
		
	target_position = path[0]
	if target_position.distance_to(global_position) < arrival_threshold:
		#print("Next target too close, skipping")
		_advance_to_next_target()
	#else:
		#print("New target set: ", target_position)
