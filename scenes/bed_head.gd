extends GameObject

@onready var sprite = $"CharacterBody2D/Sprite2D"
@onready var shader = sprite.get_material() 

@onready var layer0: TileMapLayer = $"../../Layer0"
@onready var layer1: TileMapLayer = $"../../Layer1"
@onready var tilemap: Node2D = $"../.."
@onready var game_object_handler: Node = $"../"
@onready var bed: Node = $"../Bed"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_tile = layer0.local_to_map(global_position)
	global_position = layer0.map_to_local(current_tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play(time: int):
	pass
	
func is_adjacent(player_position: Vector2i) -> bool:
	var tile_position = layer1.local_to_map(global_position)
	return tile_position in layer0.get_surrounding_cells(player_position)

func is_interactable(player_position: Vector2i) -> bool:
	var is_adjacent = is_adjacent(player_position) or bed.is_adjacent(player_position)
	return is_adjacent

func highlight() -> void:
	pass
	
func unhighlight() -> void:
	pass
	
func interact(player_position: Vector2i) -> Callable:
	return bed.interact(player_position)
