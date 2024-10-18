class_name DungeonManager extends Node2D

@export var doo_generation_bias = .5
@export var rooms_count: int = 5
@export var tileset_positions: DungeonTileSetPositions
@export var tilemap: TileMap
var _explored_rooms: Array[DungeonBlock] = []
var _unexplored_rooms: Array[DungeonBlock] = []
var _current_room: RoomBlock 

var _debug_circle_1_position: Vector2
var _debug_circle_2_position: Vector2

func _draw():
	draw_circle(_debug_circle_1_position, 25, Color.DARK_RED)
	draw_circle(_debug_circle_2_position, 25, Color.NAVY_BLUE)
	
	for block:RoomBlock in _explored_rooms:
		for side in block.doors:
			for door:DungeonDoor in side:
				if door.connecting_block != null:
					var direction: Vector2 = \
						door.connecting_block.get_world_position() - block.get_world_position()
					direction = direction.normalized()
					draw_line(
						block.get_world_position(), 
						block.get_world_position() + direction * 64,
						Color.BLACK,
						16
					)

func _ready():
	var room: RoomBlock = RoomBlock.new(Vector2i(0,0), 3, 16, tilemap, tileset_positions, doo_generation_bias)
	add_child(room)
	_unexplored_rooms.push_back(room)
	
	for i in range(rooms_count):
		if _unexplored_rooms.is_empty():
			break
		_current_room = _unexplored_rooms.pop_front()
		for j in range(4):
			for door: DungeonDoor in _current_room.doors[j]:
				if not door._is_open:
					continue
				
				# finding a door that is already connected
				var connecting_block: DungeonBlock
				for k in range(3):
					if _current_room.doors[j][k] == door\
					or _current_room.doors[j][k].connecting_block == null:
						continue
					connecting_block = _current_room.doors[j][k].connecting_block
					break
				# connect to already existing block
				if connecting_block != null:
					door.connecting_block = connecting_block
					continue
				
				# finding the position of the new block
				var position: Vector2i = door.parent_block._position
				if j == 0: # top door
					position.y -= door.parent_block._width
				elif j == 1: # left door
					position.x -= door.parent_block._width
				elif j == 2: # right door
					position.x += door.parent_block._width
				else: # bottomo door
					position.y += door.parent_block._width
				
				# checking if a block already exists in that position
				var is_position_taken: bool = false
				for block in _explored_rooms:
					if block._position == position:
						is_position_taken = true
						break
				if is_position_taken:
					continue
				for block in _unexplored_rooms:
					if block._position == position:
						is_position_taken = true
						break
				if is_position_taken:
					continue
				# generating a block at the position
				room = RoomBlock.new(position, 3, 16, tilemap, tileset_positions, doo_generation_bias)
				add_child(room)
				#await get_tree().create_timer(1).timeout  
				# connecting doors
				door.connecting_block = room
				# TODO: Open adjacent door
				
				_unexplored_rooms.push_back(room)
				#print("UnExplored rooms count: ", _unexplored_rooms.size())
		_explored_rooms.push_back(_current_room)
		queue_redraw()
		await get_tree().create_timer(.1).timeout
		#print("Explored rooms count: ", _explored_rooms.size())
	
	
	await get_tree().create_timer(1).timeout
	## removing unexplored
	for block in _unexplored_rooms:
		await get_tree().create_timer(.1).timeout
		block.remove()
	queue_redraw()
	
	print("Explored rooms count: ", _explored_rooms.size())
	print("UnExplored rooms count: ", _unexplored_rooms.size())
	
	# A pass to fix door connections
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
				print("connecting")
				block.connect_to(other_block)
				queue_redraw()
				await get_tree().create_timer(.01).timeout
	queue_redraw()
	
	# TODO: Remove all of this bs since it does not work, and implement the minimum spanning
	# tree instead
	# actually not even that will work, instead use that algorithm that u thought off for fortnite
	# destruction, the how do the platforms know they are connected to the ground,
	# so it goes as follows:
	# all rooms must point to the center/starting room
	# when a room is created, it points to one of its neighboors that is pointing to the center
	# a room can be removed if:
	#	its not the center room
	#	and nothing is point to it
	#	or its neighbors have other neighbors other than itself and at least one is not pointing to it
	# once removed, update the neighbors to point to a neighbor not pointing to them
	## removing rooms 
	var i: int = 0
	for block in _explored_rooms:
		if block.get_connections().size() == 1:
			continue
		i += 1
		print("----------")
		#await get_tree().create_timer(2).timeout
		_debug_circle_1_position = block.get_world_position()
		#queue_redraw()
		var is_can_remove: bool = true
		# getting connections count
		var connections: Array[DungeonBlock] = block.get_connections()
		# first condition is to have more than 2 connection
		if connections.size() > 2:
			# finding if the other blocks are only connected to this one
			for connected_block in connections:
				_debug_circle_2_position = connected_block.get_world_position()
				#queue_redraw()
				print(i, " ", connected_block.get_connections().size())
				#await get_tree().create_timer(2).timeout
				if connected_block.get_connections().size() <= 1:
					print("Found a block with 1 connection, skipping block removal")
					is_can_remove = false
					break
			if not is_can_remove:
				continue
			queue_redraw()
			await get_tree().create_timer(.01).timeout
			_explored_rooms.remove_at(_explored_rooms.find(block))
			block.remove()
			queue_redraw()
			await get_tree().create_timer(.05).timeout
	print("Explored rooms count: ", _explored_rooms.size())
	queue_redraw()
func _input(event):
	if event.is_action_pressed("ui_select"):  # "ui_select" is mapped to space by default in Godot
		get_tree().reload_current_scene()  # Switch to the newly loaded scene
