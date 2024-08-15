extends Path2D

var bezier_points: PackedVector2Array

func _draw():
	# drawing the curve
	for i in range(1, bezier_points.size()):
		draw_line(bezier_points[i-1], bezier_points[i], Color.AQUA, 1)
	
	# drawing the curve points
	for i in range(0, curve.point_count):
		draw_circle(curve.get_point_position(i), 2.5, Color.AQUA)

func _ready():
	if curve.point_count <= 1:
		return
		
	for point_index in range(0, curve.point_count):
		# START POINT
		if point_index == 0: 
			var direction_to_neighbor: Vector2 = (curve.get_point_position(1) - curve.get_point_position(0)).normalized()
			var distance_to_neighbor: float = curve.get_point_position(1).distance_to(curve.get_point_position(0))
			curve.set_point_out(0, direction_to_neighbor * distance_to_neighbor * .25)
			continue
		
		# END POINT
		if point_index == curve.point_count - 1: 
			var direction_to_neighbor: Vector2 = (curve.get_point_position(point_index-1) - curve.get_point_position(point_index)).normalized()
			var distance_to_neighbor: float = curve.get_point_position(point_index-1).distance_to(curve.get_point_position(point_index))
			curve.set_point_out(point_index, direction_to_neighbor * distance_to_neighbor * .25)
			continue
		
		# MID POINT
		var direction_out: Vector2 = (curve.get_point_position(point_index+1) - curve.get_point_position(point_index))
		var direction_in: Vector2 = (curve.get_point_position(point_index-1) - curve.get_point_position(point_index))
		var distance_out: float = curve.get_point_position(point_index+1).distance_to(curve.get_point_position(point_index))
		var distance_in: float = curve.get_point_position(point_index-1).distance_to(curve.get_point_position(point_index))
		var control_point_out_direction = (direction_out - direction_in).normalized()
		var control_point_in_direction = - control_point_out_direction
		
		curve.set_point_in(point_index, control_point_in_direction * distance_in * .25)
		curve.set_point_out(point_index, control_point_out_direction * distance_out * .25)
	
	bezier_points = curve.tessellate_even_length(5, 5)
	queue_redraw()
