## TODO:
## - Add a perecentage for if a room will be removed or not
## - Redo the operation if the number of rooms is smaller than some threshhold
## - Fix the walls on the edge rooms
## - Add horizontal and vertical variation
## - Look into autotiling
## - Add a chance to open the entire wall
## - Close any doors when disconnecting from a neighbor

class_name DungeonManager extends Node2D

@export var doo_generation_bias = .3
@export var rooms_count: int = 5
@export var door_size: int = 5
@export var tileset_positions: DungeonTileSetPositions
@export var tilemap: TileMap

@export_category("Debugging")
@export var is_debug: bool
@export var execution_delay: float = 0.00000001
@export var is_draw_debug_circles: bool
@export var is_draw_neighbor_connections: bool
@export var neighbor_connection_color: Color = Color.SLATE_GRAY
@export var is_draw_path_to_center: bool
@export var path_to_center_Color: Color = Color.DARK_BLUE

var _explored_rooms: Array[DungeonBlock] = []
var _unexplored_rooms: Array[DungeonBlock] = []
var _current_room: DungeonBlock 

var _debug_circle_1_position: Vector2
var _debug_circle_2_position: Vector2

func _draw():
	if not is_debug:
		return
	
	if is_draw_debug_circles:
		draw_circle(_debug_circle_1_position, 25, Color.DARK_RED)
		draw_circle(_debug_circle_2_position, 25, Color.NAVY_BLUE)
	
	if is_draw_neighbor_connections:
		for block:DungeonBlock in _explored_rooms:
			for neighbor:DungeonBlock in block.neighbors:
				if neighbor == null:
					continue
				var direction: Vector2 = neighbor.get_world_position() - block.get_world_position()
				direction = direction.normalized()
				draw_line(
					block.get_world_position(), 
					block.get_world_position() + direction * 64,
					neighbor_connection_color,
					16
				)
	
	if is_draw_path_to_center:
		for block:DungeonBlock in _explored_rooms:
			for next_block:DungeonBlock in block.next_blocks_to_center:
				var direction: Vector2 = next_block.get_world_position() - block.get_world_position()
				direction = direction.normalized()
				var head_distance: float = block.get_world_position().distance_to(
					next_block.get_world_position()
				) * .25
				var angle: int = rad_to_deg(direction.angle_to(Vector2.RIGHT))
				var offset: Vector2 = Vector2(
					50 if angle == 90 or angle == -90 else 0,
					50 if angle == -180 or angle == 0 else 0,
				)
				# arrow head
				draw_line(
					block.get_world_position() + offset + direction * (head_distance - 35),
					block.get_world_position() + direction * head_distance ,
					path_to_center_Color,
					8
				)
				offset *= -1
				draw_line(
					block.get_world_position() + direction * head_distance,
					block.get_world_position() + offset + direction * (head_distance - 35),
					path_to_center_Color,
					8
				)
				
				# arrow body
				draw_line(
					block.get_world_position(), 
					next_block.get_world_position(),
					neighbor_connection_color,
					16
				)
				draw_line(
					block.get_world_position(), 
					block.get_world_position() + direction * head_distance,
					path_to_center_Color,
					16
				)

func _ready():
	var room: RoomBlock = RoomBlock.new(
		Vector2i(0,0), door_size, 16, tilemap, tileset_positions, doo_generation_bias)
	add_child(room)
	_unexplored_rooms.push_back(room)
	
	for i in range(rooms_count):
		if _unexplored_rooms.is_empty():
			#print("All explored, breaking...")
			break
		
		_current_room = _unexplored_rooms.pop_front()
		_debug_circle_1_position = _current_room.get_world_position()
		
		# continue if no doors are open
		if _current_room.get_doors(-1, true).size() == 0: 
			#print("No doors open, moving to the next room")
			_unexplored_rooms.remove_at(_unexplored_rooms.find(_current_room))
			_current_room.remove()
			continue
			
		for side_direction in range(4):
			# checking if doors are open in this side
			if _current_room.get_doors(side_direction, true).size() == 0:
				continue
			
			# finding the position of the new block
			var neighbor_position: Vector2i = _current_room._position
			if side_direction == DungeonBlock.Direction.TOP: 
				neighbor_position.y -= _current_room._width
			elif side_direction == DungeonBlock.Direction.LEFT: 
				neighbor_position.x -= _current_room._width
			elif side_direction == DungeonBlock.Direction.RIGHT: 
				neighbor_position.x += _current_room._width
			else:
				neighbor_position.y += _current_room._width
			
			# checking if a block already exists in that position
			var blocking_block: DungeonBlock = null
			var created_blocks: Array[DungeonBlock] = []
			created_blocks.append_array(_explored_rooms)
			created_blocks.append_array(_unexplored_rooms)
			for block in created_blocks:
				if block._position == neighbor_position:
					blocking_block = block
					break
			if blocking_block != null:
				#await get_tree().create_timer(execution_delay).timeout
				# chance of closing or opening both sides if they are not neighbors
				if _current_room.neighbors.find(blocking_block) == -1\
				and blocking_block.neighbors.find(_current_room) == -1:
					if randf() <= .5:
						_current_room.change_doors_status(
							_current_room.get_block_direction(blocking_block), false)
						blocking_block.change_doors_status(
							blocking_block.get_block_direction(_current_room), false)
					else:
						_current_room.open_neighbor_adjacent_doors(blocking_block)
						_current_room.neighbors[side_direction] = blocking_block
				continue
			
			# generating a block at the position
			var neighbor = RoomBlock.new(neighbor_position, door_size, 16	, tilemap, tileset_positions, doo_generation_bias)
			add_child(neighbor)
			
			#print(rooms_count, " ", neighbor)
			#await get_tree().create_timer(execution_delay).timeout
			
			# Adding neighbor block to current block
			_current_room.neighbors[side_direction] = neighbor
			_current_room.open_neighbor_adjacent_doors(neighbor)
			
			# Connecting path to center from neighbor to current
			neighbor.next_blocks_to_center.append(_current_room)
			
			_unexplored_rooms.push_back(neighbor)
			#print("UnExplored rooms count: ", _unexplored_rooms.size())
			
		_explored_rooms.push_back(_current_room)
		queue_redraw()
		#await get_tree().create_timer(execution_delay).timeout
		#print("Explored rooms count: ", _explored_rooms.size())
	
	
	## removing unexplored
	for block in _unexplored_rooms:
		await get_tree().create_timer(execution_delay).timeout
		block.remove()
	queue_redraw()
	
	# CAUTION:
	# For some reason i have to wait for a small amount of time
	# otherwise some rooms on the edges will not be connected
	await get_tree().create_timer(0.1).timeout
	
	#print("Explored rooms count: ", _explored_rooms.size())
	#print("UnExplored rooms count: ", _unexplored_rooms.size())
	
	## A pass to fix neighbors
	for block in _explored_rooms:
		_debug_circle_1_position = (block as RoomBlock).get_world_position()

		for other_block in _explored_rooms:
			#if block.get_max_connections_count() == block.get_connections().size():
				#break
				
			# Checking if it is within distance
			var distance: float =\
				(block._position as Vector2).distance_to((other_block._position as Vector2))
			if distance > 0 and distance <= block._width:
				_debug_circle_2_position = (other_block as RoomBlock).get_world_position()
				
				# Checking if theres a door open towards that neighbor
				if block.get_doors(block.get_block_direction(other_block)).size():
					block.connect_to(other_block)
					queue_redraw()
					#await get_tree().create_timer(execution_delay).timeout
		block.close_no_neighbor_doors() # NOTE: dont wanna make another loop for this
	queue_redraw()
	
	## A pass to add missing paths to the center
	_explored_rooms.reverse() 	# NOTE: This makes it traverse the tree from the outside in
								# otherwise it would cause loops that would cut off the dungeon at the edges
	for block: DungeonBlock in _explored_rooms:
		# skipping the center block
		if block._position == Vector2i.ZERO:
			continue
			
		_debug_circle_1_position = block.get_world_position()
		for neighbor: DungeonBlock in block.neighbors:
			# if neighbor already on path, continue
			if neighbor == null or block.next_blocks_to_center.find(neighbor) != -1:
				continue
			
			_debug_circle_2_position = neighbor.get_world_position()
			queue_redraw()
			#await get_tree().create_timer(1).timeout
			# if block is not on the neighbor's path
			if neighbor.next_blocks_to_center.find(block) == -1:
				block.next_blocks_to_center.append(neighbor)
				queue_redraw()
				#await get_tree().create_timer(3).timeout
	
	queue_redraw()
	
	## removing rooms 
	for block: DungeonBlock in _explored_rooms:
		print(block)
		var is_center_block: bool = (block._position == Vector2i.ZERO)
		if is_center_block:
			print("Is center block")
			continue
		
		var is_nothing_pointing_to_block: bool = true
		var is_all_neighbors_have_extra_paths: bool = false
		
		for neighbor: DungeonBlock in block.neighbors:
			if neighbor == null:
				continue
			if neighbor.next_blocks_to_center.find(block) != 1:
				#print("Nothing pointing to block")
				is_nothing_pointing_to_block = false
				break
		if not is_nothing_pointing_to_block:
			is_all_neighbors_have_extra_paths = true
			for neighbor: DungeonBlock in block.neighbors:
				if neighbor == null:
					continue
				var path_options: int = neighbor.next_blocks_to_center.size()
				if  not (path_options > 1 or (path_options == 1 and neighbor.next_blocks_to_center.find(block) == -1)):
					#print("All neighbors dont have extra paths")
					is_all_neighbors_have_extra_paths = false
					break
		
		if is_all_neighbors_have_extra_paths:
			_explored_rooms.remove_at(_explored_rooms.find(block))
			block.remove()
			#queue_redraw()
			#await get_tree().create_timer(.01).timeout
	
func _input(event):
	if event.is_action_pressed("ui_select"):  # "ui_select" is mapped to space by default in Godot
		get_tree().reload_current_scene()  # Switch to the newly loaded scene
