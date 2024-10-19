class_name DungeonBlock extends Node2D

var _position: Vector2i = Vector2i.ZERO
## NOTE: the size of the room must always have an odd number of tiles
var _door_size_in_tiles: int
var _tile_size_in_pixels: int
var _tilemap: TileMap
var _tileset_positions: DungeonTileSetPositions
var neighbors: Array[DungeonBlock] = []
var next_blocks_to_center: Array[DungeonBlock] = []
var doors: Array[Array] = []

enum Direction
{
	TOP,
	LEFT,
	RIGHT,
	BOTTOM
}

func get_world_position() -> Vector2:
	return to_global(_tilemap.map_to_local(_position))

func get_block_direction(block: DungeonBlock) -> Direction:
	var direction: Direction = -1
	if block._position.x < _position.x: 
		direction = Direction.LEFT
	elif block._position.x > _position.x: 
		direction = Direction.RIGHT
	elif block._position.y < _position.y:
		direction = Direction.TOP
	else: 
		direction = Direction.BOTTOM
	return direction

func get_doors(direction: Direction = -1, is_open: bool = true)-> Array[DungeonDoor]:
	if direction > 3:
		print_debug("Direction ", direction, " does not exist")
		return []
	
	var open_doors: Array[DungeonDoor] = []
	if direction < 0: # Get all open doors
		for side in doors:
			for door:DungeonDoor in side:
				if door._is_open == is_open:
					open_doors.append(door)
	else:
		for door:DungeonDoor in doors[direction]:
			if door._is_open == is_open:
				open_doors.append(door)
	
	return open_doors

func change_doors_status(direction: Direction = -1, is_open: bool = true):
	if direction > 3:
		print_debug("Direction ", direction, " does not exist")
		
	if direction < 0: # change all doors status
		for side in doors:
			for door:DungeonDoor in side:
				if is_open:
					door.open()
				else:
					door.close()
	else:
		for door:DungeonDoor in doors[direction]:
			if is_open:
				door.open()
			else:
				door.close()
				
func open_neighbor_adjacent_doors(neighbor: DungeonBlock):
	var neighbor_to_current_direction: Direction = neighbor.get_block_direction(self)
	var current_to_neighbor_direction: Direction = get_block_direction(neighbor)
	var current_open_doors: Array[DungeonDoor] = get_doors(current_to_neighbor_direction)
	var current_open_doors_indecies: Array[int] = []
	
	for door:DungeonDoor in current_open_doors:
		current_open_doors_indecies.append((2 - doors[current_to_neighbor_direction].find(door)) % 3)
		#print("before: ", doors[current_to_neighbor_direction].find(door),
			#" after: ", (2 - doors[current_to_neighbor_direction].find(door)) % 3)
	
	neighbor.change_doors_status(neighbor_to_current_direction, false)
	
	for adjacent_door_index: int in current_open_doors_indecies:
		neighbor.doors[neighbor_to_current_direction][adjacent_door_index].open()







