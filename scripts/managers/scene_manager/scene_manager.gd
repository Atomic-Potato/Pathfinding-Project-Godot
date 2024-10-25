## SceneManager (Autloaded)
extends Node2D

@export var start_screen_resource:  Resource
@export var main_level_resource:  Resource

var current_scene: Scene

var scene_loaded: Signal
var scene_unloaded: Signal

func _ready():
	current_scene = get_tree().current_scene

func load_scene(scene_resource: Resource)-> void:
	# Unloading
	if current_scene != null:
		current_scene.unloaded.connect(func(): scene_unloaded.emit())
		current_scene.unload_scene()
	
	# Switching scene
	await get_tree().process_frame
	get_tree().change_scene_to_packed(load(scene_resource.resource_path))
	await get_tree().process_frame
	current_scene = get_tree().current_scene
	
	# Loading 
	current_scene.loaded.connect(func(): scene_loaded.emit())
	current_scene.load_scene()

