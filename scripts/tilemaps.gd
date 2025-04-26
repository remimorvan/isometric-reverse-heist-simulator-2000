extends Node2D

@onready var layer0: TileMapLayer = $Layer0
@onready var layer1: TileMapLayer = $Layer1
@onready var chair: TileMapLayer = $Chair

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

func make_hover_glow(position: Vector2i) -> void:
	hover_effect.position = layer0.map_to_local(position)
	hover_effect.visible = true
	
func make_select_glow(tile_position: Vector2i) -> void:
	var glow = select_effects[tile_position]
	glow.position = layer1.map_to_local(tile_position)
	glow.position[1] -= 16
	glow.visible = true

func stop_hover_glow() -> void:
	hover_effect.visible = false
	
func stop_select_glow(tile_position: Vector2i) -> void:
	select_effects[tile_position].visible = false

func _ready() -> void:
	hover_effect = create_glow(Color(1, 1, 1, 0.2), 0)
	$Layer0.add_child(hover_effect)
	# We create a glow for every cell **at layer 0**, however this
	# glow in on **layer 1**.
	# We implicitely assume that for every cell at layer 1, there is
	# a corresponding cell at layer 0.
	var cells = layer0.get_used_cells()
	for c in cells:
		select_effects[c] = create_glow(Color(1, 0.9, 0.3, 0.2), 1)
		$Layer1.add_child(select_effects[c])	

func _process(_delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var tile_pos0 = layer0.local_to_map(mouse_pos)
	var used_cells0 = layer0.get_used_cells()
	
	if used_cells0.has(tile_pos0):
		# Convert tile position back to local coordinates for the hover effect
		make_hover_glow(tile_pos0)
	else:
		stop_hover_glow()
