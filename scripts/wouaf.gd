extends GameObject

@export var move_speed: float = 100.0
@export var arrival_threshold: float = 1.0 # Smaller threshold for precise center alignment
@export var path: PackedVector2Array

var target_position: Vector2
var is_moving: bool = false

@onready var layer0: TileMapLayer = $"../../Layer0"
@onready var layer1: TileMapLayer = $"../../Layer1"

func play(tour_nb) -> void:
	var cyclic_path = []
	cyclic_path.append(Vector2(2,2))
	cyclic_path.append(Vector2(2,-2))
	cyclic_path.append(Vector2(-4,-2))
	cyclic_path.append(Vector2(-4,2))

	var start_tile = layer0.local_to_map(global_position)
	var end_tile = cyclic_path[tour_nb%4]
	
	var new_path = MovementUtils.get_path_to_tile(
		start_tile,
		end_tile,
		layer0,
		layer1
	)
	
	print(new_path)
	
	use_new_path(new_path)
	
func is_done() -> bool:
	return not is_moving
	
func _ready() -> void:
	# Snap initial position to tile center
	var current_tile = layer0.local_to_map(global_position)
	global_position = layer0.map_to_local(current_tile)
	print("Player initial position (snapped to center): ", global_position)
	#var cylic_path: PackedVector2Array
	#cyclic_path = []
	#cyclic_path.append(Vector2(2,2))
	#cyclic_path.append(Vector2(2,-2))
	#cyclic_path.append(Vector2(-4,-2))
	#cyclic_path.append(Vector2(-4,2))
	#new_parameterized_path(cyclic_path,true)
	
func new_parameterized_path(list_of_points, is_cyclic=false):
	var new_path = []
	var start_pos = list_of_points[0]
	for i in range(1,list_of_points.size()):
		var new_pos = list_of_points[i]
		var new_path2 = MovementUtils.get_path_to_tile(
				start_pos,
				new_pos,
				layer0,
				layer1
			)
		new_path.append_array(new_path2)
		start_pos = new_pos
	if is_cyclic:
		var new_path2 = MovementUtils.get_path_to_tile(
				list_of_points[-1],
				list_of_points[0],
				layer0,
				layer1
			)
		new_path.append_array(new_path2)
	
	use_new_path(new_path)
	
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
		if event.button_index == MOUSE_BUTTON_RIGHT:
			var click_pos = get_global_mouse_position()
			print("\nNew movement requested")
			print("From: ", global_position)
			print("To: ", click_pos)
			
			# Convert world positions to tile coordinates
			var start_tile = layer0.local_to_map(global_position)
			var end_tile = layer0.local_to_map(click_pos)
			
			var new_path = MovementUtils.get_path_to_tile(
				start_tile,
				end_tile,
				layer0,
				layer1
			)
			
			use_new_path(new_path)

func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if not is_moving or path.is_empty():
		return
		
	var distance_to_target = global_position.distance_to(target_position)
	#print("Distance to target: ", distance_to_target)
	
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
		#print("Moving: dir=", direction, " movement=", movement, " new_pos=", global_position)

func add_to_path(pos):
	path.append(pos)

func _advance_to_next_target() -> void:
	var pos = path[0]
	path.remove_at(0)
		
	#print("Point reached, remaining points: ", path.size())
	
	if path.is_empty():
		print("Path completed")
		is_moving = false
		return
		
	target_position = path[0]
	if target_position.distance_to(global_position) < arrival_threshold:
		#print("Next target too close, skipping")
		_advance_to_next_target()
	#else:
		#print("New target set: ", target_position)
