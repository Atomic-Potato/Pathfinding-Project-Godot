# To watch:
# https://www.youtube.com/watch?v=MtEh6vofiqQ
# https://www.youtube.com/watch?v=DkAmGxRuCk4
# https://youtu.be/QRr_P_uqz8w
# https://youtu.be/_VuYGmXiTw0

class_name Grid extends Node2D

var grid : AStarGrid2D = AStarGrid2D.new()
var grid_size_in_pixels : Vector2

@export var grid_center_position : Node2D
@onready var grid_start_position : Vector2i  :
	get :
		return grid_center_position.global_position - Vector2(cell_count * cell_size_in_pixels) / 2

@export var cell_count : Vector2i = Vector2i(16, 16)
@export var cell_size_in_pixels : Vector2i = Vector2i(8, 8)
@export var navigation_method : AStarGrid2D.Heuristic = AStarGrid2D.HEURISTIC_OCTILE
@export var diagonal_mode : AStarGrid2D.DiagonalMode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
@export var is_jumping : bool = true

@export var solid_collision_mask : Array[int] = [1]

@export var draw_debugging : bool = false
@export var grid_color : Color = Color.WHITE_SMOKE
@export var non_solid_cell_color : Color = Color.DARK_GREEN
@export var solid_cell_color : Color = Color.DARK_RED


func _draw():
	if not draw_debugging : return
	draw_grid()

func draw_grid() -> void :
	draw_rect(Rect2i(grid_start_position - cell_size_in_pixels / 2, Vector2(cell_count * cell_size_in_pixels)), grid_color)
	for i in range(0, grid.region.size.x):
		for j in range(0, grid.region.size.y):
			var id : Vector2i = Vector2i(i,j)
			var cell_position : Vector2 = grid.get_point_position(id) - Vector2(cell_size_in_pixels) / 2 
			var cell_color : Color = solid_cell_color if grid.is_point_solid(id) else non_solid_cell_color
			draw_rect(Rect2(cell_position + cell_size_in_pixels * 0.1,  cell_size_in_pixels * 0.8), cell_color)

func _enter_tree():
	GridsManager.grids.append(self)
	
func _ready():
	create_grid()
	update_solid_status()
	grid_size_in_pixels = cell_count * cell_size_in_pixels

func create_grid() -> void:
	grid.region = Rect2i(0,0, cell_count.x, cell_count.y)
	grid.offset = grid_start_position
	grid.cell_size = cell_size_in_pixels
	grid.default_compute_heuristic = navigation_method
	grid.diagonal_mode = diagonal_mode
	grid.jumping_enabled = is_jumping
	grid.update()

func update_solid_status() -> void:
	
	# Initializing a shape cast for detecting collisions
	var box_cast : ShapeCast2D = ShapeCast2D.new()
	add_child(box_cast)
	box_cast.set_collision_mask_value(1, false) # removing the first layer as it is true by default
	for layer_number in solid_collision_mask:
		box_cast.set_collision_mask_value(layer_number, true)
	box_cast.target_position = Vector2(0,0)
	
	# Giving the cast a shape
	box_cast.shape = RectangleShape2D.new()
	(box_cast.shape as RectangleShape2D).size = cell_size_in_pixels
	
	# Loop over each cell and cast a box to check for collision and mark as solid
	for i in range(0, grid.region.size.x):
		for j in range(0, grid.region.size.y):
			var id : Vector2i = Vector2i(i,j)
			var cell_position : Vector2 = grid.get_point_position(id)
			box_cast.position = cell_position
			box_cast.force_shapecast_update() # Shape cast will not apply position changes without it
			if box_cast.is_colliding():
				grid.set_point_solid(id)
	
	box_cast.queue_free()
	queue_redraw()

func get_point_path_from_positions(start_position: Vector2, end_position: Vector2) -> PackedVector2Array:
	var start_id : Vector2i = get_id_from_position(start_position)
	var end_id : Vector2i = get_id_from_position(end_position)
	return grid.get_point_path(start_id, end_id)

func get_id_from_position(world_position: Vector2) -> Vector2i:
	var position_perecent_X : float = world_position.x / (global_position.x + grid_size_in_pixels.x) + 0.5
	var position_perecent_Y : float = world_position.y / (global_position.y + grid_size_in_pixels.y) + 0.5
	
	var id : Vector2i
	id.x = abs(int(floor(clamp(cell_count.x * position_perecent_X, 0, cell_count.x-1))))
	id.y = abs(int(floor(clamp(cell_count.y * position_perecent_Y, 0, cell_count.y-1))))
	return id
