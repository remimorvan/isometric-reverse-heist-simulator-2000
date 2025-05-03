extends Node2D

func _ready() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 5
	timer.one_shot = true
	timer.timeout.connect(func(): get_tree().change_scene_to_file("res://scenes/MainLevel.tscn"))
	timer.start()
	return

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainLevel.tscn")
