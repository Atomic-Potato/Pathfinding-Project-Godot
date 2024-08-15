extends Node

var grids : Array[Grid]

func get_closest_grid(position : Vector2) -> Grid:
	if grids.size() == 1:
		return grids[0] 
	return null
	
