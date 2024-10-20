extends Area2D

func _process(delta):
	var size : int = get_overlapping_bodies().size()
	if size != 0:
		print(size)w
