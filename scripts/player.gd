extends GameObject

@export var move_speed: float = 100.0
@export var arrival_threshold: float = 1.0 # Smaller threshold for precise center alignment

var target_position: Vector2
var selected_tile: Vector2
var path: PackedVector2Array
var is_moving: bool = false

@onready var layer0: TileMapLayer = $"../../Layer0"
@onready var layer1: TileMapLayer = $"../../Layer1"
@onready var tilemap: Node2D = $"../.."
@onready var game_object_handler: Node = $"../"

func _ready() -> void:
	# Snap initial position to tile center
	var current_tile = layer0.local_to_map(global_position)
	global_position = layer0.map_to_local(current_tile)
	print("Player initial position (snapped to center): ", global_position)
	
func use_new_path(new_path):
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
		if event.button_index == MOUSE_BUTTON_LEFT:
			var click_pos = get_global_mouse_position()
			selected_tile = layer0.local_to_map(click_pos)
			print("\nNew tile selected:", selected_tile)
			
			#var new_path = MovementUtils.get_path_to_tile(
			#	start_tile,
			#	end_tile,
			#	layer0,
			#	layer1
			#)
			#
			#if not new_path.is_empty():
			#	path = new_path
			#	is_moving = true
			#	target_position = path[0]
			#	print("Path accepted, first target: ", target_position)
			#	# Validate that target is different from current position
			#	if target_position.distance_to(global_position) < arrival_threshold:
			#		print("Warning: First target too close to current position!")
			#		_advance_to_next_target()
			#else:
			#	print("Path was empty, movement cancelled")

func _process(delta: float) -> void:
	pass

func play(tour_nb):
	var start_tile = layer0.local_to_map(global_position)
	var end_tile = selected_tile
	
	unglow_all_objects()
			
	var new_path = MovementUtils.get_path_to_tile(
		start_tile,
		end_tile,
		layer0,
		layer1
	)
	
	print(new_path)
	
	use_new_path(new_path)
	
	glow_adjacent_interactable_objects(end_tile)
	
func is_done() -> bool:
	return not is_moving


func _physics_process(delta: float) -> void:
	if not is_moving or path.is_empty():
		return
		
	var distance_to_target = global_position.distance_to(target_position)
	print("Distance to target: ", distance_to_target)
	
	if distance_to_target < arrival_threshold:
		# Snap to exact center when close enough
		global_position = target_position
		_advance_to_next_target()
	else:
		var direction = (target_position - global_position).normalized()
		var movement = direction * move_speed * delta
		# Prevent overshooting by clamping movement to remaining distance
		if movement.length() > distance_to_target:
			movement = direction * distance_to_target
		global_position += movement
		print("Moving: dir=", direction, " movement=", movement, " new_pos=", global_position)

func _advance_to_next_target() -> void:
	path.remove_at(0)
	print("Point reached, remaining points: ", path.size())
	
	if path.is_empty():
		print("Path completed")
		is_moving = false
		return
		
	target_position = path[0]
	
	if target_position.distance_to(global_position) < arrival_threshold:
		print("Next target too close, skipping")
		_advance_to_next_target()
	else:
		print("New target set: ", target_position)

func unglow_all_objects() -> void:
	var interactable_objects = game_object_handler.get_interactable_objects()
	for obj in interactable_objects:
		obj.unhighlight()
			
func glow_adjacent_interactable_objects(tile: Vector2i) -> void:
	var adjacent_positions = layer0.get_surrounding_cells(tile)
	var interactable_objects = game_object_handler.get_interactable_objects()
	for obj in interactable_objects:
		if layer0.local_to_map(obj.global_position) in adjacent_positions:
			obj.highlight()
