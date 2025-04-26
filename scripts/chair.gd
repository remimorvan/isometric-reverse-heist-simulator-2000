extends GameObject

@onready var sprite = $"CharacterBody2D/Sprite2D"
#@onready var shader = sprite.get_material() 

var init_scale: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_scale = sprite.scale

func highlight() -> void:
	sprite.scale = init_scale*1.4
	
func unhighlight() -> void:
	sprite.scale = init_scale

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func is_interactable() -> bool:
	return true
