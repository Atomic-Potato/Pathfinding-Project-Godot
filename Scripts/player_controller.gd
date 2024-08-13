extends Node2D

@export_range(0, 100) var drag_min_distance_threshold : float = 10
@export var selection_collision_mask: Array[int] = [2]

@export var is_debugging: bool = true
@export var selection_area_color: Color = Color.AQUA

var grid: Grid

var selection_start_position: Vector2
var selection_end_position: Vector2
var selection_size: Vector2
var selection_area: Area2D = Area2D.new()
var selection_area_shape: RectangleShape2D = RectangleShape2D.new()
var selection_area_position: Vector2

var selection_cast : RayCast2D = RayCast2D.new()

var selection: Array[Agent] = []
var new_selection: Array[Agent] = []

signal on_mouse_drag_end
signal on_mouse_tap
signal on_mouse_tap_params(Vector2, int)

func _draw():
	if not is_debugging:
		return
		
	if Input.is_action_pressed("Select"):
		var end_position: Vector2 = get_global_mouse_position()
		var size: Vector2 = Vector2(
			end_position.x - selection_start_position.x, 
			end_position.y - selection_start_position.y
		)
		draw_rect(Rect2(selection_start_position, size), selection_area_color, false, 1)

func _enter_tree():
	
	setup_selection_cast_node()
	setup_selection_area_node()
	on_mouse_drag_end.connect(set_new_selection_area)
	on_mouse_tap.connect(select_new_agent_in_cast)
	selection_area.area_entered.connect(select_new_agent_in_area)
	empty_selection()

func _ready():
	grid = GridsManager.get_closest_grid(global_position)
	on_mouse_tap_params.connect(get_adjacent_cells)
	
func setup_selection_area_node() -> void:
	# setting up the area
	add_child(selection_area)
	selection_area.monitorable = false
	selection_area.set_collision_layer_value(1, false) # I don't need anything to collide with this
	selection_area.set_collision_mask_value(1, false) # removing the first layer as it is true by default
	for layer_number in selection_collision_mask:
		selection_area.set_collision_mask_value(layer_number, true)

	# setting up the collision shape
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	selection_area.add_child(collision_shape)
	selection_area_shape.size = Vector2.ZERO
	collision_shape.shape = selection_area_shape

func setup_selection_cast_node() -> void:
	add_child(selection_cast)
	selection_cast.target_position = Vector2.ZERO
	selection_cast.hit_from_inside = true
	selection_cast.collide_with_areas = true
	selection_cast.collide_with_bodies = false
	selection_cast.set_collision_mask_value(1, false) # removing the first layer as it is true by default
	for layer_number in selection_collision_mask:
		selection_cast.set_collision_mask_value(layer_number, true)
	selection_cast.force_raycast_update()
	
func _process(delta):
	if Input.is_action_pressed("Select"):
		queue_redraw()

func _input(event):
	if event.is_action_pressed("Select"):
		selection_start_position = get_global_mouse_position()
		
	elif event.is_action_released("Select"):
		selection_end_position = get_global_mouse_position()
		
		var selection_distance = selection_start_position.distance_to(selection_end_position)
		if selection_distance <= drag_min_distance_threshold:
			on_mouse_tap.emit()
			on_mouse_tap_params.emit(selection_end_position, 1)
		else:
			on_mouse_drag_end.emit()
		queue_redraw()
	
	elif  event.is_action_pressed("Clear Unit Selection"):
		empty_selection()
		
	elif event.is_action_pressed("Navigate Unit(s)"):
		navigate_selection_to_mouse()

func select_new_agent_in_cast() -> void:
	empty_selection()
	selection_cast.global_position = get_global_mouse_position()
	selection_cast.force_update_transform()
	selection_cast.force_raycast_update()
	var collider : Node = selection_cast.get_collider() as Node
	if collider and collider.get_parent() is Agent:
		add_agent_to_selection(collider.get_parent())

func select_new_agent_in_area(body: Area2D) -> void:
	if body.get_parent() is Agent:
		add_agent_to_selection(body.get_parent())
		body.force_update_transform()
	disable_selection_area()

func set_new_selection_area() -> void:
	# setting the selection size
	selection_size = Vector2(
		abs(selection_start_position.x - selection_end_position.x), 
		abs(selection_start_position.y - selection_end_position.y)
	)
	selection_area_shape.size = selection_size 

	# setting the selection area position
	var distance_between_start_end: float = selection_start_position.distance_to(selection_end_position)
	var direction_to_end: Vector2 = (selection_end_position - selection_start_position).normalized()
	selection_area_position = selection_start_position + direction_to_end * (distance_between_start_end * 0.5)
	selection_area.global_position = selection_area_position
	selection_area.force_update_transform()
	
	empty_selection()
	queue_redraw()

func add_agent_to_selection(agent: Agent) -> void:
	selection.append(agent)
	agent.sprite.self_modulate = Color.WHITE
	agent.sprite.force_update_transform()

func disable_selection_area() -> void:
	if (selection_area_shape.size != Vector2.ZERO):
		selection_area_shape.size = Vector2.ZERO

func empty_selection() -> void:
	#for agent in selection:
		#var color: Color = Color(Color.WHITE, 0.5)
		#agent.sprite.self_modulate = color
	selection.clear()

func navigate_selection_to_mouse() -> void:
	if selection.size() == 0:
		return
	
	var mouse_position : Vector2 = get_global_mouse_position()
	var mouse_cell: Vector2i = grid.get_id_from_position(mouse_position)
	if not grid.grid.is_point_solid(mouse_cell):
		var avliable_cells = get_adjacent_cells(mouse_position, selection.size())
		var j: int = 0
		for cell in avliable_cells:
			selection[j].navigate_to(grid.grid.get_point_position(cell))
			j = (j+1) % selection.size()

func get_adjacent_cells(start_position: Vector2, adjacent_count: int) -> Array[Vector2i]:
	var adjacent_cells: Array[Vector2i]
	var explored_cells : Dictionary = {}
	var starting_cell: Vector2i = grid.get_id_from_position(start_position)
	var queue: Array[Vector2i]
	queue.append(starting_cell)
	adjacent_cells.append(starting_cell)
	
	while queue.size() > 0 and adjacent_count > 0:
		var cell: Vector2i = queue.pop_front()
		var i = cell.x
		var j = cell.y
		
		if i < 0 or i >= grid.cell_count.x or j < 0 or j >= grid.cell_count.y or explored_cells.has(cell) or grid.grid.is_point_solid(cell):
			continue
		
		explored_cells[cell] = true
		adjacent_cells.append(cell)
		queue.append(Vector2i(i+1, j))
		queue.append(Vector2i(i-1, j))
		queue.append(Vector2i(i, j+1))
		queue.append(Vector2i(i, j-1))
		
		adjacent_count -= 1
	return adjacent_cells















