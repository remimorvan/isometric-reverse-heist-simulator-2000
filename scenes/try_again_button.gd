extends Button

func _ready():
	text = "Try again"
	pressed.connect(_button_pressed)

func _button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainLevel.tscn")
