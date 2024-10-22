extends Node2D

@export var _dungeon_manager_resource: Resource
@export var _pathfinding_grid_manager_resource: Resource

var dungeon_manager: DungeonManager
var pathfinding_grid_manager: GridsManager

func _ready():
	SceneManager.load_scene(SceneManager.main_level)
	
func _input(event):
	if event.is_action_pressed("ui_select"):
		print("Scene reloaded")
		get_tree().reload_current_scene()
