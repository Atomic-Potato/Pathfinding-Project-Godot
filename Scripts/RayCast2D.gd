extends RayCast2D



func _process(delta):
	if (is_colliding()):
		print(is_colliding())
