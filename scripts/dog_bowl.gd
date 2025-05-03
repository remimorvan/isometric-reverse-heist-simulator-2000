extends GameObject

@onready var sprite = $"CharacterBody2D/Sprite2D"
@onready var shader = sprite.get_material() 

@onready var layer0: TileMapLayer = $"../../Layer0"
@onready var layer1: TileMapLayer = $"../../Layer1"
@onready var tilemap: Node2D = $"../.."
@onready var game_object_handler: Node = $"../"
@onready var dog: Node = $"../Chien"

var is_highlighted: bool = false
var should_move: bool = false
var next_position:= Vector2i(0,0)

@export var nb_turns_until_empty = 11#13
const delay_until_dog_comes = 0
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

func is_non_empty() -> bool:
	# State <= nb_turns_until_empty is necessary, otherwise dog will go to bowl as soon as it is filled.
	return state > 0 && state <= nb_turns_until_empty

func update_sprite() -> void:
	sprite.texture = get_texture()

func dog_is_adjacent() -> bool:
	return game_object_handler.tile_of_object(dog) in layer0.get_surrounding_cells(game_object_handler.tile_of_object(self))

func play(time: int):
	# print("[Dog bowl]: ", state, "/", nb_turns_until_empty, " -> ", state == nb_turns_until_empty + 1)
	if state >= nb_turns_until_empty:
		state -= 1
	elif state > 0 and dog_is_adjacent():
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
		$ServeFreeFood.play()
		state = nb_turns_until_empty + delay_until_dog_comes
		update_sprite()
	return func(player): pass
