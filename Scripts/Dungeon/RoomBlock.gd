class_name RoomBlock extends DungeonBlock

## Contains if a door is open or closed and is of size 3x4
## The rows are as following:
## 0: Top / 1: Left / 2: Right / 3: Bottom 
var doors_status: Array[Array] = []
var _door_generation_bias: float

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

func _ready():
	
	# Generating the room on the tilemap
	# NOTE TO SELF: to get from the number of tiles from the center to one of the sides is:
	# 		door_size + ceil(door_size/2) + 1
	# NOTE: We add 1 since rooms will always have an odd number of tiles for their width/height
	var room_half_width: int = _door_size_in_tiles + int(ceil(float(_door_size_in_tiles) * .5)) + 1
	var room_width = room_half_width * 2 - 1
	var top_left_tile_position: Vector2i = Vector2i(
		_position.x - (room_half_width - 1),
		_position.y - (room_half_width - 1)
	)
	var bottom_right_tile_position: Vector2i = Vector2i(
		_position.x + (room_half_width - 1),
		_position.y + (room_half_width - 1)
	)
	#print("Room half width : " + str(room_half_width), "\nRoom width : ", room_width)
	#print("Top left tile position: ", top_left_tile_position)
	#print("Bottom right tile position: ", bottom_right_tile_position)
	
	## Placing corner tiles
	_tilemap.set_cell(0, top_left_tile_position, 0, _tileset_positions._solid)
	_tilemap.set_cell(0, bottom_right_tile_position, 0, _tileset_positions._solid)
	_tilemap.set_cell(0, Vector2i(
		top_left_tile_position.x, bottom_right_tile_position.y
		), 0, _tileset_positions._solid)
	_tilemap.set_cell(0, Vector2i(
		bottom_right_tile_position.x, top_left_tile_position.y
		), 0, _tileset_positions._solid)
	
	# Initializing the doors array
	#for i in range(4):
		#var doors: Array[bool] = []
		#for j in range(3):
			#var status: bool = false if randf() > _door_generation_bias else true
			#doors.append(status)
		#doors_status.append(doors)
	#
 
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
				top_left_tile_position.x + _door_size_in_tiles * i - floor(_door_size_in_tiles * .5) - 1,
				top_left_tile_position.y 
			),
			_door_size_in_tiles,
			self,
			null,
			_door_generation_bias
		)
		var door_bottom: DungeonDoor = DungeonDoor.new(
			_tileset_positions,
			_tilemap,
			DungeonDoor.Horizontal,
			Vector2i(
				bottom_right_tile_position.x - (_door_size_in_tiles * i - floor(_door_size_in_tiles * .5)) - 1,
				bottom_right_tile_position.y 
			),
			_door_size_in_tiles,
			self,
			null,
			_door_generation_bias
		)
		
		# vertical doors
		var door_left: DungeonDoor = DungeonDoor.new(
			_tileset_positions,
			_tilemap,
			DungeonDoor.Vertical,
			Vector2i(
				top_left_tile_position.x,
				top_left_tile_position.y + _door_size_in_tiles * i - floor(_door_size_in_tiles * .5) - 1
			),
			_door_size_in_tiles,
			self,
			null,
			_door_generation_bias
		)
		var door_right: DungeonDoor = DungeonDoor.new(
			_tileset_positions,
			_tilemap,
			DungeonDoor.Vertical,
			Vector2i(
				bottom_right_tile_position.x,
				bottom_right_tile_position.y - (_door_size_in_tiles * i - floor(_door_size_in_tiles * .5)) - 1
			),
			_door_size_in_tiles,
			self,
			null,
			_door_generation_bias
		)
		add_child(door_top)
		add_child(door_bottom)
		add_child(door_left)
		add_child(door_right)
	
	## Filling the inside tiles
	for y in range(top_left_tile_position.y + 1, top_left_tile_position.y - 1 + room_width):
		for x in range(top_left_tile_position.x + 1, top_left_tile_position.x - 1 + room_width):
			_tilemap.set_cell(0, Vector2i(x, y), 0, _tileset_positions._non_solid)
			await get_tree().create_timer(0.01).timeout 
