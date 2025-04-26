class_name GameObject
extends Node2D

#============================================================
#	Parent class of all objects in game that plays
#   at a given turn, must be called by the handler
#   All functions should be overriden
#============================================================

#called by the handler, prepare an action or a sequence of actions at turn t
func play(time: int) -> void:
	pass
	
#for the handler, say if the object is done
func is_done() -> bool:
	return true

func is_interactable(player_position: Vector2i) -> bool:
	return false
	
func unhighlight() -> void:
	pass
