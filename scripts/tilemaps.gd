extends Node2D

@onready var layer0: TileMapLayer = $Layer0
@onready var layer1: TileMapLayer = $Layer1
@onready var dog: GameObject = $GameObjectHandler/Chien
@onready var handler: Node2D = $GameObjectHandler
@onready var player: Node2D = $"GameObjectHandler/Player"
@export var window_vision_distance = 5
@onready var camera: Node2D = $"Camera2D"

var walkable_tiles : Array[Vector2i]
var dog_FOV_effects: Array[Polygon2D]
var highlight_interactable_tiles: Dictionary[Vector2i, Polygon2D]
var hover_effect: Polygon2D
@export var tile_size = 480.
var game_over: bool = false

const color_interactable_tile = Color(1.0, 0.9, 0.3, 1.0)

func create_glow(color: Color, layer_index: int) -> Polygon2D:
	var glow = Polygon2D.new()
	glow.polygon = PackedVector2Array([
		Vector2(0, -tile_size*0.5), # Top
		Vector2(tile_size, 0), # Right
		Vector2(0, tile_size*0.5), # Bottom
		Vector2(-tile_size, 0) # Left
	])
	glow.color = color
	glow.visible = false
	glow.z_index = layer_index
	return glow

func make_glow(position: Vector2i, obj: Polygon2D) -> void:
	obj.position = layer0.map_to_local(position)
	obj.visible = true

func stop_glow(obj: Polygon2D) -> void:
	obj.visible = false

func _ready() -> void:
	# hover effect for the mouseover selection
	hover_effect = create_glow(Color(1, 1, 1, 0.2), 0)
	$Layer0.add_child(hover_effect)
	
	# Effect for interactable tiles
	
	for pos in layer0.get_used_cells():
		highlight_interactable_tiles[pos] = create_glow(color_interactable_tile,0)
		$Layer0.add_child(highlight_interactable_tiles[pos])
	
	# effect for the dog FOV
	var all_tiles = layer0.get_used_cells()
	var blocked_tiles = layer1.get_used_cells()
	walkable_tiles = all_tiles.filter(func(tile): 
		return not blocked_tiles.has(tile))
	
	dog_FOV_effects = []
	
	for pos in walkable_tiles:
		dog_FOV_effects.append(create_glow(Color(1, 0, 0, 0.4), 0))
		$Layer0.add_child(dog_FOV_effects[-1])

func _process(_delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var tile_pos0 = layer0.local_to_map(mouse_pos)
	var used_cells0 = layer0.get_used_cells()
	
	if handler.interactable_tiles_should_glow():
		var player_tile = handler.tile_of_object(player)
		var surrounding_tiles = layer0.get_surrounding_cells(player_tile)
		var occupied_tiles = handler.occupied_tiles()
		for pos in layer0.get_used_cells():
			if pos in surrounding_tiles and pos not in occupied_tiles:
			# Change alpha level depending on system time (glowing effect)
				highlight_interactable_tiles[pos].color.a = 0.2+0.8*abs(sin(Time.get_unix_time_from_system()))
				make_glow(pos, highlight_interactable_tiles[pos])
			else:
				stop_glow(highlight_interactable_tiles[pos])
	
	if used_cells0.has(tile_pos0):
		# Convert tile position back to local coordinates for the hover effect
		make_glow(tile_pos0, hover_effect)
	else:
		stop_glow(hover_effect)
	
	var all_tiles = layer0.get_used_cells()
	var blocked_tiles1 = layer1.get_used_cells()
	walkable_tiles = all_tiles.filter(func(tile): 
		return not blocked_tiles1.has(tile))
		
	#print(walkable_tiles)
	var player = $GameObjectHandler/Player
	var player_tile = layer0.local_to_map(player.global_position)
	var closet_pos1 = layer0.local_to_map($GameObjectHandler/Closet.global_position)
	var closet_pos2 = layer0.local_to_map($GameObjectHandler/Closet2.global_position)
	var blocked_tiles = $GameObjectHandler.occupied_tiles_but_objs([dog,player])
	blocked_tiles.append(closet_pos1)
	blocked_tiles.append(closet_pos2)
	for i in range(walkable_tiles.size()):
		var do_glow = false
		var pos = walkable_tiles[i]
		var effect = dog_FOV_effects[i]
		var dog_tile = layer0.local_to_map(dog.global_position)
		var dog_dir = dog.view_dir
		#print("View dir:", dog_dir, " tile:", dog_tile)
		
		# check dog vision
		if MovementUtils.check_visibility(dog_tile, dog_dir, pos, blocked_tiles, 0.7, 1000):
			if pos == player_tile and pos != closet_pos1 and pos != closet_pos2:
				_launch_game_over(layer0.map_to_local(dog_tile))
			do_glow = true
			
		# Window positions + viewdir
		# -3, 2		;	1, 0
		# -1, -7	;	0, 1
		# -7, -5	;	1, 0
		# check window vision
		# I'm sorry for however has to look at this - Timothé
		
		var window_positions = [Vector2i(-3,2), Vector2i(-1,-7), Vector2i(-7,-6)]
		var windows = [$GameObjectHandler/WindowPeopleMainRoomKitchen,
					   $GameObjectHandler/WindowPeopleMainRoom,
					   $GameObjectHandler/WindowPeopleBedroom]
		var window_directions = [Vector2i(1,0),Vector2i(0,1),Vector2i(1,0)]
		for j in range(3):
			var window = windows[j]
			var window_pos = window_positions[j]
			var window_dir = window_directions[j]
			var otherwindow = window_positions[j] +	 Vector2i(window_dir.y, window_dir.x)
			var bed1 = Vector2i(-6,-6)
			var bed2 = Vector2i(-6,-5)
			var extras = [window_pos, otherwindow, bed1, bed2]
			var blocked_minus_extras = blocked_tiles.filter(func(o): return !extras.has(o))
			if MovementUtils.check_visibility(window_pos, window_dir, pos, 
					blocked_minus_extras, 0.7, window_vision_distance) and window.is_mean_person():
				do_glow = true
				if pos == player_tile and pos != closet_pos1 and pos != closet_pos2:
					print("Window : ", window_positions[j])
					_launch_game_over(layer0.map_to_local(window_pos))
					
		
		if do_glow:
			make_glow(pos, effect)
		else:
			stop_glow(effect)

func _launch_game_over(position: Vector2):
	if not game_over:
		game_over = true
		var timer := Timer.new()
		add_child(timer)
		timer.wait_time = 2
		timer.one_shot = true
		camera.global_position = position 
		var final_zoom = camera.zoom*3
		var tw = create_tween().set_parallel().set_trans(Tween.TRANS_ELASTIC)
		#tw.tween_property(camera, "global_position", position, 1)
		tw.tween_property(camera, "zoom", final_zoom, 1.5)
		timer.timeout.connect(func(): get_tree().change_scene_to_file("res://scenes/game_over_screen.tscn"))
		timer.start()
		await tw.finished
