class_name GameManager extends Node2D

@export var _dungeon_manager_resource: Resource
@export var _pathfinding_grid_manager_resource: Resource

var dungeon_manager: DungeonManager
var pathfinding_grid_manager: GridsManager

func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("ui_select"):
		get_tree().reload_current_scene()
