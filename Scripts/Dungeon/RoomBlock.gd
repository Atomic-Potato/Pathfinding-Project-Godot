class_name RoomBlock extends DungeonBlock


var _door_generation_bias: float
var _half_width: int
var _width: int
var _top_left_tile_position: Vector2i
var _bottom_right_tile_position: Vector2i


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
	
	## Initializing the doors array
	for i in range(4):
		var empty_doors: Array[DungeonDoor] = []
		doors.append(empty_doors)
	
	## Initializing the neighbors array
	for i in range(4):
		neighbors.append(null)
	
func _ready():
	
	## Placing corner tiles
	_tilemap.set_cell(0, _top_left_tile_position, 0, _tileset_positions._solid_horizontal)
	_tilemap.set_cell(0, _bottom_right_tile_position, 0, _tileset_positions._solid_horizontal)
	_tilemap.set_cell(0, Vector2i(
		_top_left_tile_position.x, _bottom_right_tile_position.y
		), 0, _tileset_positions._solid_horizontal)
	_tilemap.set_cell(0, Vector2i(
		_bottom_right_tile_position.x, _top_left_tile_position.y
		), 0, _tileset_positions._solid_horizontal)
	
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

func connect_to(block: DungeonBlock) -> bool:
	if block._position == _position or block == null:
		print("RoomBlock.gd: ", self, " cant connect to block: ", block)
		return false
	
	var direction: Direction = get_block_direction(block)
	neighbors[direction] = block
	
	return true

func disconnect_from(block: DungeonBlock) -> bool:
	var is_block_neighbor: bool = true if neighbors.find(block) != -1 else false 
	if not is_block_neighbor or block == null:
		print("RoomBlock.gd: ", self, " cannot disconect from: ", block)
		return false
	
	var direction: Direction = get_block_direction(block)
	neighbors[direction] = null
	for door:DungeonDoor in doors[direction]:
		door.close()
	return true


func get_max_connections_count() -> int:
	var max: int = 0
	for side in doors:
		for door in side:
			if door._is_open:
				max += 1
			break
	return max

func remove():
	## Disconnecting from connected blocks
	for neighbor:DungeonBlock in neighbors:
		if neighbor == null:
			continue
		neighbor.disconnect_from(self)
	
	## Removing doors
	for side in doors:
		for door:DungeonDoor in side:
			door.remove()
	
	## Removing neighbors path connection
	for neighbor:DungeonBlock in neighbors:
		if neighbor == null:
			continue
		neighbor.next_blocks_to_center.remove_at(neighbor.next_blocks_to_center.find(self))
	
	## Removing the tiles
	for y in range(_top_left_tile_position.y, _top_left_tile_position.y + _width):
		for x in range(_top_left_tile_position.x, _top_left_tile_position.x + _width):
			_tilemap.erase_cell(0, Vector2i(x, y))
	queue_free()
