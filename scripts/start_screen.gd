extends Node2D

@onready var letter0: Node = $"Letter0"
@onready var letter1: Node = $"Letter1"

func _on_first_button_pressed() -> void:
	letter0.visible = false
	letter1.visible = true

func _on_second_button_pressed() -> void:
	self.visible = false
	queue_free()
