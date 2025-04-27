extends Node2D

@onready var layer0: TileMapLayer = $Layer0
@onready var layer1: TileMapLayer = $Layer1

var hover_effect: Polygon2D
@export var tile_size = 16.

func create_glow(color: Color, layer_index: int) -> Polygon2D:
	var glow = Polygon2D.new()
	glow.polygon = PackedVector2Array([
		Vector2(0, -tile_size*0.5), # Top
		Vector2(tile_size, 0), # Right
		Vector2(0, tile_size*0.5), # Bottom
		Vector2(-tile_size, 0) # Left
	])
	glow.color = color
	glow.visible = false
	glow.z_index = layer_index
	return glow

func make_hover_glow(position: Vector2i) -> void:
	hover_effect.position = layer0.map_to_local(position)
	hover_effect.visible = true

func stop_hover_glow() -> void:
	hover_effect.visible = false

func _ready() -> void:
	hover_effect = create_glow(Color(1, 1, 1, 0.2), 0)
	$Layer0.add_child(hover_effect)

func _process(_delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var tile_pos0 = layer0.local_to_map(mouse_pos)
	var used_cells0 = layer0.get_used_cells()
	
	if used_cells0.has(tile_pos0):
		# Convert tile position back to local coordinates for the hover effect
		make_hover_glow(tile_pos0)
	else:
		stop_hover_glow()
