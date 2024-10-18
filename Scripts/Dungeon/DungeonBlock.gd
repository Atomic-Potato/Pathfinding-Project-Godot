class_name DungeonBlock extends Node2D

var _position: Vector2i = Vector2i.ZERO
## NOTE: the size of the room must always have an odd number of tiles
var _door_size_in_tiles: int
var _tile_size_in_pixels: int
var _tilemap: TileMap
var _tileset_positions: DungeonTileSetPositions
