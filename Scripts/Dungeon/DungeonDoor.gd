class_name DungeonDoor extends Node2D

var _orientation: int = Horizontal
var _position: Vector2i = Vector2i.ZERO
# NOTE: Size must always be an odd number
var _size: int = 0
var parent_block: DungeonBlock
var _is_open: bool = false
var _tilemap: TileMap
var _tileset_positions: DungeonTileSetPositions

enum
{
	Horizontal,
	Vertical
}

func _init(
		tileset_positions: DungeonTileSetPositions,
		tilemap: TileMap,
		orientation: int = Horizontal,
		position: Vector2i = Vector2i.ZERO,
		size: int = 0,
		parent_block: DungeonBlock = null,
		is_open_bias: float = 0.5
	):
	
	_orientation = orientation
	_position = position
	_size = size
	self.parent_block = parent_block
	_is_open = true if randf() < is_open_bias else false
	_tileset_positions = tileset_positions
	_tilemap = tilemap

func _ready():
	## Placing the door tiles
	var starting_positions: Vector2i = Vector2i(
		_position.x - floor(_size * .5),
		_position.y - floor(_size * .5)
	)
	for i in range(1, _size + 1):
		var tile_position: Vector2i
		if _orientation == Horizontal:
			tile_position = Vector2i(
				starting_positions.x + i,
				_position.y
			)
		else:
			tile_position = Vector2i(
				_position.x,
				starting_positions.y + i,
			)
		_tilemap.set_cell(0, tile_position, 0,
			_tileset_positions._door if _is_open else _tileset_positions._solid
		)

# INFO: The default value of (-1,-1) indicates that you erase the tile 
func _replace_tiles(tileset_tile_position: Vector2i = Vector2i(-1,-1)):
	var starting_positions: Vector2i = Vector2i(
		_position.x - floor(_size * .5),
		_position.y - floor(_size * .5)
	)
	for i in range(1, _size + 1):
		var tile_position: Vector2i
		if _orientation == Horizontal:
			tile_position = Vector2i(
				starting_positions.x + i,
				_position.y
			)
		else:
			tile_position = Vector2i(
				_position.x,
				starting_positions.y + i,
			)
		if (tileset_tile_position == Vector2i(-1,-1)):
			_tilemap.erase_cell(0, tile_position)
		else:
			_tilemap.set_cell(0, tile_position, 0, tileset_tile_position)

func open() -> void:
	_replace_tiles(_tileset_positions._door)
	_is_open = true

func close() -> void:
	_replace_tiles(_tileset_positions._solid)
	_is_open = false

# INFO: Deletes the door node and its tiles
func remove():
	_replace_tiles()
	await get_tree().create_timer(.5).timeout
	queue_free()
