extends GameObject

@onready var layer0: TileMapLayer = $"../../Layer0"
@onready var player: GameObject = $"../Player"
@onready var collision: CollisionShape2D = $"CharacterBody2D/CollisionShape2D"

var final_position: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_tile = layer0.local_to_map(global_position)
	global_position = layer0.map_to_local(current_tile)
	final_position = global_position
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
	collision.set_deferred("disabled", true)
	visible = true
	var final_scale = scale
	scale = Vector2i(0,0)
	var tw = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(self, "scale", final_scale, 0.3)
	tw.tween_property(self, "modulate:a", 1.0, 0.3)
	await tw.finished
	#global_position = player.global_position
	#z_index = 2
