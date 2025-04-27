class_name MovementUtils
extends Node

static func get_path_to_tile(
	start_tile: Vector2,
	end_tile: Vector2,
	tilemap: TileMapLayer,
	blocked_tiles: Array
) -> PackedVector2Array:
	# If start and end are the same tile, return empty path
	if start_tile == end_tile:
		print("Start and end tiles are the same")
		return PackedVector2Array([])
	
	# Get all walkable tiles (excluding blocked tiles)
	var all_tiles = tilemap.get_used_cells()
	var walkable_tiles = all_tiles.filter(func(tile): return not blocked_tiles.has(tile))
	print("Total tiles: ", all_tiles.size(), ", Blocked tiles: ", blocked_tiles.size(), ", Walkable tiles: ", walkable_tiles.size())
	
	# Create AStar2D pathfinder
	var astar = AStar2D.new()
	
	# Add points for all walkable tiles
	for tile in walkable_tiles:
		var point_id = _get_point_id(tile)
		# Store tile coordinates for pathfinding
		astar.add_point(point_id, Vector2(tile))
	
	# Connect points with their neighbors
	for tile in walkable_tiles:
		var point_id = _get_point_id(tile)
		
		#print("Tile:", tile, " with neighbors: ",  _get_neighbors(tile))
		# Check orthogonal neighbors for isometric grid
		for neighbor in _get_neighbors(tile):
			if walkable_tiles.has(neighbor):
				var neighbor_id = _get_point_id(neighbor)
				if not astar.are_points_connected(point_id, neighbor_id):
					astar.connect_points(point_id, neighbor_id)
	
	# Get start and end point IDs
	var start_id = _get_point_id(start_tile)
	var end_id = _get_point_id(end_tile)
	
	# Return empty path if either start or end is not in the graph
	if not astar.has_point(start_id) or not astar.has_point(end_id):
		print("No valid path: start or end point not in graph")
		return PackedVector2Array([])
	
	# Get path in tile coordinates
	var tile_path = astar.get_point_path(start_id, end_id)
	
	# Convert tile path to world coordinates
	var world_path: PackedVector2Array = PackedVector2Array([])
	for tile_pos in tile_path:
		var world_pos = tilemap.map_to_local(Vector2i(tile_pos))
		# Include all points to ensure precise center-to-center movement
		world_path.append(world_pos)
		print("Adding world pos to path: ", world_pos)
	
	print("Final path length: ", world_path.size())
	if world_path.is_empty():
		print("Warning: Generated path is empty!")
	else:
		print("First path point: ", world_path[0])
	return world_path

static func check_visibility(dog_tile : Vector2i, dog_dir: Vector2, 
							 target_tile : Vector2i, blocked_tiles: Array, 
							 cosangle_min, distance_max) -> bool:
	var current_tile = Vector2(dog_tile)
	var displacement : Vector2 = Vector2(target_tile)-current_tile
	var dir = displacement.normalized()
	var cosangle = dog_dir.dot(dir)
	if cosangle < cosangle_min:
		return false	# not in vision cone
		
	#print("in vision cone", dog_dir, cosangle, player_pos, global_position)
	
	var tile_distance = displacement.length()
	
	if tile_distance > distance_max:
		return false
	
	var steps = 10.

	for t in range(ceil(tile_distance * steps)):
		var position = t * dir / steps + current_tile
		var tile = Vector2i(round(position.x), round(position.y))
		#print(dt, dir," ",tile, " ", t, " dist: ", tile_distance)
		#print("Wala: ", blocked_tiles)
		if blocked_tiles.has(tile):
			#print("hit blocking tile")
			return false
	return true


static func _get_point_id(tile: Vector2i) -> int:
	# Convert 2D coordinates to unique ID
	var a = tile.x + 10000
	var b = tile.y + 10000
	return (a + b) * (a + b + 1) / 2 + b

static func _get_neighbors(tile: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	# Only orthogonal neighbors for isometric grid
	neighbors.append(Vector2i(tile.x + 1, tile.y))
	neighbors.append(Vector2i(tile.x - 1, tile.y))
	neighbors.append(Vector2i(tile.x, tile.y + 1))
	neighbors.append(Vector2i(tile.x, tile.y - 1))
	return neighbors
