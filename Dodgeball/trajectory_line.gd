extends Line2D
func update_trajectory(dir: Vector2, speed: float, gravity: float, points: int,  delta: float):
	var max_points: int = points
	clear_points()
	var vel: Vector2 = dir * speed
	var point_pos: Vector2 = Vector2.ZERO
	for i  in max_points:
		add_point(point_pos)
		
		vel.y += gravity * delta
		point_pos += vel * delta
