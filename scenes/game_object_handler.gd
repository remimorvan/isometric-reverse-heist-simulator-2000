extends Node

@export var turn_nb = 0

@onready var layer0: TileMapLayer = $"../Layer0"
@onready var layer1: TileMapLayer = $"../Layer1"

func new_turn():
	for obj in self.get_children():
		obj.play(turn_nb)
	
	turn_nb += 1

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
	return layer0.local_to_map(obj.global_position)

func occupied_tiles(tile: Vector2i) -> Array:
	var layer1_tiles = layer1.get_used_cells()
	var objects = get_children()
	return layer1_tiles + objects.map(tile_of_object)

func is_tile_valid(tile: Vector2i) -> bool:
	return tile in layer0.get_used_cells()
	
func is_tile_free(tile: Vector2i) -> bool:
	return tile not in occupied_tiles(tile)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			if turn_finished():
				print("New turn", turn_nb)
				new_turn()
			else:
				print("Wait for end of turn")
