extends Node

@export var turn_nb = 0

@onready var layer0: TileMapLayer = $"../Layer0"
@onready var layer1: TileMapLayer = $"../Layer1"
@onready var player: GameObject = 	$"Player"

var turn_processing: bool = false #is the turn in process?
var prepare_turn: bool = false #are we waiting to play other's units turn?

func _process(delta: float) -> void:
	if player.is_done() and prepare_turn:
		prepare_turn = false
		play_others_turns()
		turn_nb += 1
	if turn_processing and turn_finished():
		turn_processing = false
		player.glow_interactable_objects(tile_of_object(player))

func turn_finished() -> bool:
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
	return not turn_processing # turn_finished()

#first play player's turn, then wait for its end to player the other's turn
func make_new_turn() -> void:
	print("[Game Object Handler] New turn: ", turn_nb)
	player.unglow_all_objects()
	player.play(turn_nb)
	turn_processing = true
	prepare_turn = true

#play the other objects turn AFTER the player
func play_others_turns() -> void:
	for obj in get_children():
		if obj != player:
			obj.play(turn_nb)
	#if can_play():
	#	print("Turn ", turn_nb)
	#	for obj in get_children():
	#		obj.play(turn_nb)
	#	turn_nb += 1
	#print("Error: Wait for end of turn")
