class_name Agent extends RigidBody2D

@export var speed : float = 10
@export var is_skip_first_point : bool = true
@export var is_debugging : bool = false
@export var path_color : Color = Color.BLUE
@export var sprite : Sprite2D

var grid : Grid
var grid_cell_size : Vector2
var path : PackedVector2Array
var path_index : int

var direction : Vector2
var velocity : Vector2

func _draw():
	if not is_debugging:
		return
	
	# Drawing the path from the agent's position to the first path point
	if path_index < path.size():
		draw_line(global_position - position, path[path_index]- position, path_color, 1)
	
	# Drawing the rest of the path
	for i in range(path_index, path.size() - 1):
		draw_line(path[i] - position, path[i + 1] - position, path_color, 1)
	
	# Optionally, draw rectangles or other debug visuals around path points
	for i in range(path_index, path.size()):
		var point : Vector2 = path[i]
		draw_rect(Rect2(point - position - Vector2(grid.cell_size_in_pixels) / 2 + grid.cell_size_in_pixels * 0.1, grid.cell_size_in_pixels * 0.8), path_color)

		
func _ready():
	grid = GridsManager.get_closest_grid(global_position)

func _process(delta):
	if path_index < path.size():
		direction = (path[path_index] - global_position).normalized()
		velocity = direction * speed
		global_position += velocity * delta
		
		var distance : float = global_position.distance_to(path[path_index])
		if distance < 2:
			path_index += 1
		queue_redraw()
	else:
		velocity = Vector2.ZERO

func navigate_to(target_position: Vector2) -> void:
	path = grid.get_point_path_from_positions(global_position, target_position)
	path_index = 0 if not is_skip_first_point else 1
	queue_redraw() 
