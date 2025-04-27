extends GameObject

@onready var layer0: TileMapLayer = $"../../Layer0"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_tile = layer0.local_to_map(global_position)
	global_position = layer0.map_to_local(current_tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play(time: int):
	pass

func is_interactable(player_position: Vector2i) -> bool:
	return false
	
func occupies_space() -> bool:
	return false
	
func highlight() -> void:
	pass
	
func unhighlight() -> void:
	pass
