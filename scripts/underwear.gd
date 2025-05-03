extends GameObject

@onready var layer0: TileMapLayer = $"../../Layer0"
@onready var player: GameObject = $"../Player"
@onready var sprite: Sprite2D = $"CharacterBody2D/Sprite2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var current_tile = layer0.local_to_map(global_position)
	#global_position = layer0.map_to_local(current_tile)
	visible = false

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
	
func appear() -> void:
	visible = true
	var final_scale = scale
	var final_position = global_position
	scale = final_scale*0.1
	global_position = player.global_position
	var tw = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(self, "scale", final_scale, 1)
	tw.tween_property(self, "modulate:a", 1.0, 1)
	tw.tween_property(self, "global_position", final_position, 1)
	tw.tween_property(sprite, "rotation", PI*10, 1)
	await tw.finished
	#global_position = player.global_position
	#z_index = 2
