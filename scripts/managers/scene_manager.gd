extends Node2D

@export var start_screen_resource:  Resource
var start_screen: Node

@export var main_level_resource:  Resource
var main_level: Node

func load_scene(scene_resource: Resource)-> void:
	match scene_resource:
		start_screen_resource:
			pass
		main_level_resource:
			main_level = load(main_level_resource.resource_path).instantiate()
			get_tree().get_root().add_child(main_level)
			get_tree().get_root().get_child(0).queue_free()
	pass
