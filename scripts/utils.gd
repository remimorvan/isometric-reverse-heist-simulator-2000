class_name Utils
extends Node

static func are_tile_adjacent(pos1: Vector2i, pos2: Vector2i):
	return abs(pos1[0] - pos2[0]) + abs(pos1[1] - pos2[1]) == 1

static func get_adjacent_tiles(pos: Vector2i):
	var adjacent_tiles: Array = []
	for delta in [-1, 1]:
		adjacent_tiles.append(pos + Vector2i(delta, 0))
		adjacent_tiles.append(pos + Vector2i(0, delta))
	return adjacent_tiles
