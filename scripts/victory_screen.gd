extends Node2D

func _ready():
	$BoiteaSonDeGameOver.play()

func _on_button_0_pressed() -> void:
	get_tree().quit()
