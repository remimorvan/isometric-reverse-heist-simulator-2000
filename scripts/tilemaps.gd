extends Node2D

@onready var layer0: TileMapLayer = $Layer0
@onready var layer1: TileMapLayer = $Layer1

var hover_effect: Polygon2D


func _ready() -> void:
	hover_effect = Glow.create_glow()
	add_child(hover_effect)

func _process(_delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var tile_pos = layer0.local_to_map(mouse_pos)
	var used_cells = layer0.get_used_cells()
	
	if used_cells.has(tile_pos):
		# Convert tile position back to local coordinates for the hover effect
		Glow.make_tile_glow(hover_effect, layer0.map_to_local(tile_pos))
	else:
		Glow.stop_tile_glow(hover_effect)
