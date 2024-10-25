class_name Scene extends Node

var loaded: Signal
var unloaded: Signal

func load_scene():
	loaded.emit()

func unload_scene():
	unloaded.emit()
