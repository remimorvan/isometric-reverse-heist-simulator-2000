class_name Glow
extends Node2D

@onready var layer0: TileMapLayer = $Layer0
@onready var layer1: TileMapLayer = $Layer1

static func create_glow() -> Polygon2D:
	var hover_effect = Polygon2D.new()
	hover_effect.polygon = PackedVector2Array([
		Vector2(0, -8), # Top
		Vector2(16, 0), # Right
		Vector2(0, 8), # Bottom
		Vector2(-16, 0) # Left
	])
	hover_effect.color = Color(1, 1, 1, 0.2)
	hover_effect.visible = false
	return hover_effect

static func make_tile_glow(hover_effect: Polygon2D, position) -> void:
	hover_effect.position = position
	hover_effect.visible = true

static func stop_tile_glow(hover_effect: Polygon2D) -> void:
	hover_effect.visible = false
