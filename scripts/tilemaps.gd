extends Node2D

@onready var layer0: TileMapLayer = $Layer0
@onready var layer1: TileMapLayer = $Layer1

var hover_effect: Polygon2D
var select_effects: Dictionary

func create_glow(color: Color, layer_index: int) -> Polygon2D:
	var glow = Polygon2D.new()
	glow.polygon = PackedVector2Array([
		Vector2(0, -8), # Top
		Vector2(16, 0), # Right
		Vector2(0, 8), # Bottom
		Vector2(-16, 0) # Left
	])
	glow.color = color
	glow.visible = false
	glow.z_index = layer_index
	return glow

func make_tile_glow(glow: Polygon2D, layer: TileMapLayer, position: Vector2i) -> void:
	glow.position = layer.map_to_local(position)
	glow.position[1] -= glow.z_index * 16
	glow.visible = true

func stop_tile_glow(glow: Polygon2D) -> void:
	glow.visible = false

func _ready() -> void:
	hover_effect = create_glow(Color(1, 1, 1, 0.2), 0)
	$Layer0.add_child(hover_effect)
	var cells1 = layer1.get_used_cells()
	for c in cells1:
		print("\n\nCell:\n", c, "\n\n")
		select_effects[c] = create_glow(Color(1, 0.9, 0.3, 0.2), 1)
		$Layer1.add_child(select_effects[c])	
		make_tile_glow(select_effects[c], layer1, c)

func _process(_delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var tile_pos = layer0.local_to_map(mouse_pos)
	var used_cells = layer0.get_used_cells()
	
	if used_cells.has(tile_pos):
		# Convert tile position back to local coordinates for the hover effect
		make_tile_glow(hover_effect, layer0, tile_pos)
	else:
		stop_tile_glow(hover_effect)
