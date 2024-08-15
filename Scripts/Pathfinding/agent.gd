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
	
		
func _ready():
	grid = GridsManager.get_closest_grid(global_position)

func _process(delta):
	follow_path(delta)

func follow_path(delta: float) -> void:
	pass
	
func navigate_to(target_position: Vector2) -> void:
	path = grid.get_point_path_from_positions(global_position, target_position)
	path_index = 0 if not is_skip_first_point else 1
	queue_redraw() 
