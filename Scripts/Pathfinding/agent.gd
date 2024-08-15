class_name Agent extends RigidBody2D

@export var speed : float = 10
@export var is_skip_first_point : bool = true
@export var is_use_smooth_path: bool = true

@export_category('Debugging')
@export var is_debugging : bool = false
@export var path_color : Color = Color.BLUE

@export_category('Required Nodes')
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
		
	if is_use_smooth_path:
		draw_smooth_path()
	else:
		draw_straight_path()
		
func draw_smooth_path() -> void:
	# drawing the curve
	for i in range(path_index, path.size()):
		draw_line(path[i-1] - position, path[i] - position, Color.AQUA, 1)
	
	# drawing the curve points
	#for i in range(0, curve.point_count):
		#draw_circle(curve.get_point_position(i), 2.5, Color.AQUA)
	
func draw_straight_path() -> void:
	# Drawing the path from the agent's position to the first path point
	if path_index < path.size():
		draw_line(global_position - position, path[path_index]- position, path_color, 1)
	
	# Drawing the rest of the path
	for i in range(path_index, path.size() - 1):
		draw_line(path[i] - position, path[i + 1] - position, path_color, 1)
	
	# drawing path points
	for i in range(path_index, path.size()):
		var point : Vector2 = path[i]
		draw_rect(Rect2(point - position - Vector2(grid.cell_size_in_pixels) / 2 + grid.cell_size_in_pixels * 0.1, grid.cell_size_in_pixels * 0.8), path_color)


func _ready():
	grid = GridsManager.get_closest_grid(global_position)

func _process(delta):
	follow_path(delta)

func follow_path(delta: float) -> void:
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
	if is_use_smooth_path: path = create_smooth_path(path)
	path_index = 0 if not is_skip_first_point else 1
	queue_redraw() 

func create_smooth_path(points: PackedVector2Array, bezier_intensitiy: float = 0.375)-> PackedVector2Array:
	if points.size() <= 1:
		return points

	var curve: Curve2D = Curve2D.new()
		
	for i in range(0, points.size()):
		# START POINT
		if i == 0: 
			var direction_to_neighbor: Vector2 = (points[1] - points[0]).normalized()
			var distance_to_neighbor: float = points[1].distance_to(points[0])
			curve.add_point(points[i], direction_to_neighbor * distance_to_neighbor * bezier_intensitiy)
			continue
		
		# END POINT
		if i == points.size() - 1: 
			var direction_to_neighbor: Vector2 = (points[i-1] - points[i]).normalized()
			var distance_to_neighbor: float = points[i-1].distance_to(points[i])
			curve.add_point(points[i], direction_to_neighbor * distance_to_neighbor * bezier_intensitiy)
			continue
		
		# MID POINT
		var direction_out: Vector2 = (points[i+1] - points[i])
		var direction_in: Vector2 = (points[i-1] - points[i])
		var distance_out: float = points[i+1].distance_to(points[i])
		var distance_in: float = points[i-1].distance_to(points[i])
		var control_point_out_direction = (direction_out - direction_in).normalized()
		var control_point_in_direction = - control_point_out_direction
		
		curve.add_point(points[i], 
			control_point_in_direction * distance_in * bezier_intensitiy, 
			control_point_out_direction * distance_out * bezier_intensitiy)
	
	return curve.tessellate_even_length(5,5)
	
	
	
	
	
	
	





	
