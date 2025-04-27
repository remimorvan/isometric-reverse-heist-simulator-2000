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

const nb_turns_until_empty = 13
var state = 0; # How many turns left until empty

var full_bowl: Resource
var semi_full_bowl: Resource
var semi_empty_bowl: Resource
var empty_bowl: Resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	full_bowl = load("res://assets/level/gamelle/gamelle-1.png")
	semi_full_bowl = load("res://assets/level/gamelle/gamelle-2.png")
	semi_empty_bowl = load("res://assets/level/gamelle/gamelle-3.png")
	empty_bowl = load("res://assets/level/gamelle/gamelle-4.png")
	var current_tile = layer0.local_to_map(global_position)
	global_position = layer0.map_to_local(current_tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_texture() -> Resource:
	if state == 0:
		return empty_bowl
	if state <= 4:
		return semi_empty_bowl
	if state <= 9:
		return semi_full_bowl
	return full_bowl

func update_sprite() -> void:
	sprite.texture = get_texture()

func play(time: int):
	if state > 0:
		print("> Todo: play() of dog_bowl. Play sound and empty only if dog is adjacent.")
		state -= 1
		update_sprite()
	
func is_adjacent(player_position: Vector2i) -> bool:
	var tile_position = layer1.local_to_map(global_position)
	return tile_position in layer0.get_surrounding_cells(player_position)

func is_interactable(player_position: Vector2i) -> bool:
	var is_adjacent = is_adjacent(player_position)
	return is_adjacent and state == 0

func highlight() -> void:
	#sprite.scale = init_scale*1.4
	shader.set_shader_parameter("clr", Vector4(1.0, 0.9, 0.2, 1.0))
	
func unhighlight() -> void:
	#sprite.scale = init_scale
	shader.set_shader_parameter("clr", Vector4(1.0, 0.9, 0.2, 0.0))
	
func interact(player_position: Vector2i) -> Callable:
	if state == 0:
		state = nb_turns_until_empty
		update_sprite()
	return func(player): pass
