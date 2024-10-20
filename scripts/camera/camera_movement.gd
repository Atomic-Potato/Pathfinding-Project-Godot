class_name CameraMovement extends Camera2D

@export var log_speed_barrier: float = 100
@export var log_speed_multiplier: float = 100
@export var zoom_speed: float = .1
@export var zoom_step: float = .2
@export var max_zoom_in: Vector2 = Vector2(4,4)
@export var max_zoom_out: Vector2 = Vector2(.1,.1)

var _input_direction: Vector2i = Vector2i.ZERO
var zoom_target: Vector2

func _ready():
	zoom_target = zoom

func _process(delta):
	_update_position(delta)
	_update_zoom(delta)
	
	
func _input(event):
	_update_input_direction()

func _update_input_direction():
	_input_direction = Vector2i.ZERO
	if Input.is_action_pressed("Up"):
		_input_direction.y -= 1
	if Input.is_action_pressed("Down"):
		_input_direction.y += 1
	if Input.is_action_pressed("Left"):
		_input_direction.x -= 1
	if Input.is_action_pressed("Right"):
		_input_direction.x += 1

func _update_position(delta):
	var log_speed: float = log_speed_multiplier * log((max_zoom_in.x + log_speed_barrier) / (zoom.x))
	position = lerp(position, position + (_input_direction as Vector2), log_speed * delta)

func _update_zoom(delta):
	if Input.is_action_just_pressed("Zoom In") or Input.is_action_pressed("Zoom In"):
		zoom_target *= (1 + zoom_step) 
	elif Input.is_action_just_pressed("Zoom Out") or Input.is_action_pressed("Zoom Out"):
		zoom_target *= (1 - zoom_step)
		 
	zoom_target = zoom_target.clamp(max_zoom_out, max_zoom_in)
	zoom = lerp(zoom, zoom_target, zoom_speed * delta)
