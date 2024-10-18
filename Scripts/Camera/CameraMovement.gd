class_name CameraMovement extends Camera2D

@export var speed: float = 1
var _input_direction: Vector2i = Vector2i.ZERO

func _process(delta):
	position += _input_direction * speed
	
func _input(_event):
	_input_direction = Vector2i.ZERO
	if Input.is_action_pressed("Up"):
		_input_direction.y -= 1
	if Input.is_action_pressed("Down"):
		_input_direction.y += 1
	if Input.is_action_pressed("Left"):
		_input_direction.x -= 1
	if Input.is_action_pressed("Right"):
		_input_direction.x += 1
	
