extends GameObject

@onready var sprite = $"CharacterBody2D/Sprite2D"
@onready var shader = sprite.get_material() 

@onready var layer0: TileMapLayer = $"../../Layer0"
@onready var layer1: TileMapLayer = $"../../Layer1"
@onready var tilemap: Node2D = $"../.."
@onready var game_object_handler: Node = $"../"

var is_highlighted: bool = false
var should_move: bool = false
var next_position:= Vector2i(0,0)

func occupies_space() -> bool:
	return true
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_tile = layer0.local_to_map(global_position)
	global_position = layer0.map_to_local(current_tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func get_texture() -> Resource:
#	if state == 0:
#		return empty_bowl
#	if state <= 4:
#		return semi_empty_bowl
#	if state <= 9:
#		return semi_full_bowl
#	return full_bowl

func update_sprite() -> void:
	#sprite.texture = get_texture()
	pass

func play(time: int):
	pass
	
func is_adjacent_or_in(player_position: Vector2i) -> bool:
	var tile_position = layer1.local_to_map(global_position)
	return tile_position == player_position or tile_position in layer0.get_surrounding_cells(player_position)

func is_interactable(player_position: Vector2i) -> bool:
	print("[Closet] Is interactable: ", is_adjacent_or_in(player_position))
	return is_adjacent_or_in(player_position)

func highlight() -> void:
	shader.set_shader_parameter("clr", Vector4(1.0, 0.9, 0.2, 1.0))
	rotation = PI
	
func unhighlight() -> void:
	shader.set_shader_parameter("clr", Vector4(1.0, 0.9, 0.2, 0.0))
	rotation = 0
	
func _result_of_interact(player:GameObject) -> void:
	var start_tile = game_object_handler.tile_of_object(player)
	var end_tile = game_object_handler.tile_of_object(self)
	player.selected_tile = end_tile
	#print("[Closet] Start tile:", start_tile, " end tile: ", end_tile)
	if start_tile != end_tile:
		var new_path = MovementUtils.get_path_to_tile(
			start_tile,
			end_tile,
			layer0,
			get_parent().occupied_tiles_but_objs([player, self])
		)
		player._use_new_path(new_path)
	#else:
		#print("[Closet] Staying inside the closet... :|")
	player.visible = false
	
func interact(player_position: Vector2i) -> Callable:
	return _result_of_interact
		
