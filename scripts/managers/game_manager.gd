## GameManager (Autoloaded)
extends Node2D

@export var general_tilemap_cell_pixel_size: Vector2i = Vector2i(16,16) 

func _ready():
	SceneManager.load_scene(SceneManager.main_level_resource)

func _input(event):
	if event.is_action_pressed("ui_select"):
		get_tree().reload_current_scene()
