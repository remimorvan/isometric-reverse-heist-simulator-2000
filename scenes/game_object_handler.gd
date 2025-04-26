extends Node

@export var turn_nb = 0

func new_turn():
	for obj in self.get_children():
		obj.play(turn_nb)
	
	turn_nb += 1

func turn_finished():
	for obj in self.get_children():
		if not obj.is_done():
			return false
	return true

func get_interactable_objects(player_position: Vector2i) -> Array:
	var output = []
	for obj in get_children():
		if obj.is_interactable(player_position):
			output.append(obj)
	return output
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			if turn_finished():
				print("New turn", turn_nb)
				new_turn()
			else:
				print("Wait for end of turn")
