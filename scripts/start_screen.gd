extends Node2D

@onready var letter0: Node = $"Letter0"
@onready var letter1: Node = $"Letter1"

func _on_first_button_pressed() -> void:
	$Letter.play()
	letter0.visible = false
	letter1.visible = true

func _on_second_button_pressed() -> void:
	self.visible = false
	get_tree().change_scene_to_file("res://scenes/intermediate_screen.tscn")
