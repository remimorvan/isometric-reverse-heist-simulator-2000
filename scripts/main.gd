extends Node2D

@onready var background: Sprite2D = $Background
var initial_position: Vector2
var initial_y_position: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = background.global_position
	initial_y_position = background.global_position[1]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	background.global_position += Vector2(0,200)*delta
	if background.global_position[1] >= initial_y_position + 1080 * background.scale[1]:
		background.global_position = initial_position


func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainLevel.tscn")
