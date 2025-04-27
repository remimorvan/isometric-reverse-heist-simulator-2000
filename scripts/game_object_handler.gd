extends Node

@export var turn_nb = 0

@onready var layer0: TileMapLayer = $"../Layer0"
@onready var layer1: TileMapLayer = $"../Layer1"

func turn_finished():
	for obj in self.get_children():
		if not obj.is_done():
			return false
	return true

func get_interactable_objects(player_position: Vector2i) -> Array:
	var output = []
	for obj in get_children():
		if obj.is_interactable(player_position):
			output.append(obj)
	return output
	
func tile_of_object(obj: Node2D) -> Vector2i:
	# print(layer0)
	# print(get_parent().get_children())
	return layer0.local_to_map(obj.global_position)

func occupied_tiles() -> Array:
	var layer1_tiles = layer1.get_used_cells()
	var objects = get_children()
	objects = objects.filter(func(x): return x.occupies_space())
	return layer1_tiles + objects.map(tile_of_object)

func occupied_tiles_but_objs(obj_list: Array) -> Array:
	var layer1_tiles = layer1.get_used_cells()
	var objects = get_children()
	var positions_to_remove = obj_list.map(tile_of_object)
	objects = objects.filter(func(x): return x.occupies_space() and tile_of_object(x) not in positions_to_remove)
	return layer1_tiles + objects.map(tile_of_object)

func is_tile_valid(tile: Vector2i) -> bool:
	return tile in layer0.get_used_cells()
	
func is_tile_free(tile: Vector2i) -> bool:
	return tile not in occupied_tiles()
	
func can_play() -> bool:
	return turn_finished()
		
func make_new_turn() -> void:
	if can_play():
		print("[Game Object Handler] Turn ", turn_nb)
		for obj in get_children():
			obj.play(turn_nb)
		turn_nb += 1
	print("[Game Object Handler] Error: Wait for end of turn")
