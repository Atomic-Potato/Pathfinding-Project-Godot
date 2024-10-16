class_name DungeonManager extends Node

@export var tileset_positions: DungeonTileSetPositions
@export var tilemap: TileMap
var room: RoomBlock 

func _ready():
	room = RoomBlock.new(Vector2i(0,0), 3, 16, tilemap, tileset_positions, .5)
	add_child(room)

func _input(event):
	if event.is_action_pressed("ui_select"):  # "ui_select" is mapped to space by default in Godot
		get_tree().reload_current_scene()  # Switch to the newly loaded scene
