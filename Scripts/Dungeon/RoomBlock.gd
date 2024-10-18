class_name RoomBlock extends DungeonBlock

## Contains if a door is open or closed and is of size 3x4
## The rows are as following:
## 0: Top / 1: Left / 2: Right / 3: Bottom 
var doors: Array[Array] = []
var _door_generation_bias: float
var _half_width: int
var _width: int
var _top_left_tile_position: Vector2i
var _bottom_right_tile_position: Vector2i

enum Direction
{
	TOP,
	LEFT,
	RIGHT,
	BOTTOM
}

func _init(
		position: Vector2i,
		door_size_in_tiles: int,
		tile_size_in_pixels: int,
		tilemap:TileMap,
		tileset_positions: DungeonTileSetPositions,
		door_generation_bias: float = 0.5
	):
	
	_position = position
	_tilemap = tilemap
	_tileset_positions = tileset_positions
	_door_size_in_tiles = door_size_in_tiles if fmod(float(door_size_in_tiles),2.0) != 0.0 \
		else door_size_in_tiles + 1
	_tile_size_in_pixels = tile_size_in_pixels
	_door_generation_bias = door_generation_bias

	# NOTE TO SELF: to get from the number of tiles from the center to one of the sides is:
	# 		door_size + ceil(door_size/2) + 1
	# NOTE: We add 1 since rooms will always have an odd number of tiles for their width/height
	_half_width = _door_size_in_tiles + int(ceil(float(_door_size_in_tiles) * .5)) + 1
	_width = _half_width * 2 - 1
	#print("Room half width : " + str(room_half_width), "\nRoom width : ", room_width)
	_top_left_tile_position = Vector2i(
		_position.x - (_half_width - 1),
		_position.y - (_half_width - 1)
	)
	_bottom_right_tile_position = Vector2i(
		_position.x + (_half_width - 1),
		_position.y + (_half_width - 1)
	)
	#print("Top left tile position: ", top_left_tile_position)
	#print("Bottom right tile position: ", bottom_right_tile_position)
	
func _ready():
	
	## Placing corner tiles
	_tilemap.set_cell(0, _top_left_tile_position, 0, _tileset_positions._solid)
	_tilemap.set_cell(0, _bottom_right_tile_position, 0, _tileset_positions._solid)
	_tilemap.set_cell(0, Vector2i(
		_top_left_tile_position.x, _bottom_right_tile_position.y
		), 0, _tileset_positions._solid)
	_tilemap.set_cell(0, Vector2i(
		_bottom_right_tile_position.x, _top_left_tile_position.y
		), 0, _tileset_positions._solid)
	
	##Initializing the doors array
	for i in range(4):
		var empty_doors: Array[DungeonDoor] = []
		doors.append(empty_doors)
 
	## Generating doors
	# NOTE: To find the position of each door use the following equation
	# corner_position.x/y +/- door_size * i - floor(door_size * .5) +/- 1
	# i honestly dont know why we +/- 1 at the end
	for i in range(1,4):
		# horizontal doors
		var door_top: DungeonDoor = DungeonDoor.new(
			_tileset_positions,
			_tilemap,
			DungeonDoor.Horizontal,
			Vector2i(
				_top_left_tile_position.x + _door_size_in_tiles * i - floor(_door_size_in_tiles * .5) - 1,
				_top_left_tile_position.y 
			),
			_door_size_in_tiles,
			self,
			null,
			_door_generation_bias
		)
		doors[0].append(door_top)
		var door_bottom: DungeonDoor = DungeonDoor.new(
			_tileset_positions,
			_tilemap,
			DungeonDoor.Horizontal,
			Vector2i(
				_bottom_right_tile_position.x - (_door_size_in_tiles * i - floor(_door_size_in_tiles * .5)) - 1,
				_bottom_right_tile_position.y 
			),
			_door_size_in_tiles,
			self,
			null,
			_door_generation_bias
		)
		doors[3].append(door_bottom)
		
		# vertical doors
		var door_left: DungeonDoor = DungeonDoor.new(
			_tileset_positions,
			_tilemap,
			DungeonDoor.Vertical,
			Vector2i(
				_top_left_tile_position.x,
				_top_left_tile_position.y + _door_size_in_tiles * i - floor(_door_size_in_tiles * .5) - 1
			),
			_door_size_in_tiles,
			self,
			null,
			_door_generation_bias
		)
		doors[1].append(door_left)
		var door_right: DungeonDoor = DungeonDoor.new(
			_tileset_positions,
			_tilemap,
			DungeonDoor.Vertical,
			Vector2i(
				_bottom_right_tile_position.x,
				_bottom_right_tile_position.y - (_door_size_in_tiles * i - floor(_door_size_in_tiles * .5)) - 1
			),
			_door_size_in_tiles,
			self,
			null,
			_door_generation_bias
		)
		doors[2].append(door_right)
		add_child(door_top)
		add_child(door_bottom)
		add_child(door_left)
		add_child(door_right)

	## Filling the inside tiles
	for y in range(_top_left_tile_position.y + 1, _top_left_tile_position.y - 1 + _width):
		for x in range(_top_left_tile_position.x + 1, _top_left_tile_position.x - 1 + _width):
			_tilemap.set_cell(0, Vector2i(x, y), 0, _tileset_positions._non_solid)

func get_world_position() -> Vector2:
	return to_global(_tilemap.map_to_local(_position))

func connect_to(block: DungeonBlock) -> bool:
	if block._position == _position or block == null:
		print("cant connect to room")
		return false
	
	var direction: Direction
	
	if block._position.x < _position.x: 
		direction = Direction.LEFT
	elif block._position.x > _position.x: 
		direction = Direction.RIGHT
	elif block._position.y < _position.y:
		direction = Direction.TOP
	else: 
		direction = Direction.BOTTOM
	
	for door:DungeonDoor in doors[direction]:
		if door._is_open:
			door.connecting_block = block
	
	return true

func disconnect_from(block: DungeonBlock):
	for side in doors:
		for door:DungeonDoor in side:
			if door.connecting_block == block:
				door.connecting_block = null
				return 

func get_max_connections_count() -> int:
	var max: int = 0
	for side in doors:
		for door in side:
			if door._is_open:
				max += 1
			break
	return max

func get_connections() -> Array[DungeonBlock]:
	var connections: Array[DungeonBlock] = []
	for side in doors:
		for door in side:
			if door.connecting_block != null:
				connections.append(door.connecting_block)
				continue
	return connections

func get_adjacent_block(direction: Direction) -> DungeonBlock:
	match direction:
		Direction.TOP:
			for i in range(3):
				if doors[0][i].connecting_block:
					return doors[0][i].connecting_block
		Direction.LEFT:
			for i in range(3):
				if doors[1][i].connecting_block:
					return doors[1][i].connecting_block
		Direction.RIGHT:
			for i in range(3):
				if doors[2][i].connecting_block:
					return doors[2][i].connecting_block
		Direction.BOTTOM:
			for i in range(3):
				if doors[3][i].connecting_block:
					return doors[3][i].connecting_block
	return null

func remove():
	## Disconnecting from connected blocks
	for side in doors:
		for door:DungeonDoor in side:
			if door.connecting_block != null:
				door.connecting_block.disconnect_from(self)
	
	## Removing doors
	for side in doors:
		for door:DungeonDoor in side:
			door.remove()
	
	## Removing the tiles
	for y in range(_top_left_tile_position.y, _top_left_tile_position.y + _width):
		for x in range(_top_left_tile_position.x, _top_left_tile_position.x + _width):
			_tilemap.erase_cell(0, Vector2i(x, y))
	queue_free()
