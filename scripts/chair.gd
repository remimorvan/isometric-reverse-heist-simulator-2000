extends GameObject

@onready var sprite = $"CharacterBody2D/Sprite2D"
@onready var shader = sprite.get_material() 

@onready var layer0: TileMapLayer = $"../../Layer0"
@onready var layer1: TileMapLayer = $"../../Layer1"
@onready var tilemap: Node2D = $"../.."
@onready var game_object_handler: Node = $"../"

var is_highlighted: bool = false
var should_move: bool = false
var next_position:= Vector2i(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_tile = layer0.local_to_map(global_position)
	global_position = layer0.map_to_local(current_tile)
	print("[Chair] Initial position:", global_position)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play(time: int):
	return
	if should_move:
		should_move = false
		global_position = layer0.map_to_local(next_position)
	
func is_adjacent(player_position: Vector2i) -> bool:
	var tile_position = layer1.local_to_map(global_position)
	return tile_position in layer0.get_surrounding_cells(player_position)

func get_opposite_tile(player_position: Vector2i) -> Vector2i:
	var tile_position = layer1.local_to_map(global_position)
	return 2*tile_position-player_position

func is_interactable(player_position: Vector2i) -> bool:
	var opposite_tile = get_opposite_tile(player_position)
	return is_adjacent(player_position) and game_object_handler.is_tile_valid(opposite_tile) and game_object_handler.is_tile_free(opposite_tile)

func highlight() -> void:
	#sprite.scale = init_scale*1.4
	shader.set_shader_parameter("clr", Vector4(1.0, 0.9, 0.2, 1.0))
	
func unhighlight() -> void:
	#sprite.scale = init_scale
	shader.set_shader_parameter("clr", Vector4(1.0, 0.9, 0.2, 0.0))

func _result_of_interact(player:GameObject, old_position:Vector2i) -> void:
	print("YOLO",old_position,layer1.local_to_map(player.global_position))
	player.selected_tile = old_position
	
func interact(player_position: Vector2i) -> Callable:
	var old_pos = layer1.local_to_map(global_position)
	var ret = func(p): _result_of_interact(p, old_pos)
	global_position = layer0.map_to_local(get_opposite_tile(player_position))
	return ret
