extends CharacterBody2D
@export var FRICTION: float = 0.0
@export var ACCEL: float = 0.0
@export var MAX_SPEED: float = 0.0
@onready var sprite: Sprite2D = $PlayerSprite
@onready var trajectory_line: Line2D = $TrajectoryLine
var pseudo_mouse_pos: Vector2 = Vector2.ZERO
var pseudo_mouse_radius: int =  75

var input_vector: Vector2 = Vector2.ZERO
var held_ball: DodgeBall = null
var is_aiming: bool = false
var aim_direction: Vector2 = Vector2.ZERO
var throw_force: float = 0.0


func _get_nearest_pickupable_ball() -> DodgeBall:
	var interactable_balls: Array = get_tree().get_nodes_in_group("InteractableBalls")
	var closest_distance: float = INF
	var closest_ball: DodgeBall = null
	for ball in interactable_balls:
		var curr_ball_distance = global_position.distance_to(ball.global_position)
		if curr_ball_distance < closest_distance:
			closest_ball = ball
			closest_distance = curr_ball_distance
	return closest_ball
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pseudo_mouse_pos = get_global_mouse_position()
		
func _pickup_ball() -> void:
	var closest_ball = _get_nearest_pickupable_ball()
	if closest_ball: 
		closest_ball.handle_pickup(self)
		held_ball = closest_ball
		

	
func _start_aim() -> void:
	is_aiming = true
	trajectory_line.visible = true
	
func _aim_throw(delta: float) -> void:
	var mouse_pos: Vector2 = pseudo_mouse_pos
	var direction_to_mouse: Vector2 = mouse_pos.direction_to(Vector2.ZERO)
	var angle_to_mouse = Vector2.ZERO.angle_to_point(mouse_pos)
	var distance_to_mouse: float = mouse_pos.distance_to(Vector2.ZERO)
	var points = distance_to_mouse / 3
	var power = distance_to_mouse * 5
	
	var offset_angle = deg_to_rad(0) # or use radians directly
	var rotated_direction = direction_to_mouse.rotated(offset_angle)
	held_ball.ground_line_direction = rotated_direction
	 
	held_ball.ground_line_offset = Vector2(
		global_position.x ,
		global_position.y + 50
	)
	#held_ball.ground_line_offset = Vector2(global_position.x + 20 * sign(direction_to_mouse.x), global_position.y + 50 * sign(direction_to_mouse.y))
	trajectory_line.update_trajectory(direction_to_mouse, power, held_ball.GRAVITY * 0.6, points, delta)
	throw_force = power
	aim_direction = direction_to_mouse
	
func _throw_ball(ball: DodgeBall) -> void:
	#ball.floor_position = global_position.y + 10
	ball.apply_throw_force(aim_direction, throw_force)
	held_ball = null
	is_aiming = false
	trajectory_line.visible = false
	
func get_facing_direction() -> int:
	if sprite.flip_h:
		return 1
	return -1
	
func _handle_input() -> void:
	#The input vectors main purpose is to be mutliplied by the speed to move in the desired direction
	input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_vector.x = 1
		sprite.flip_h = true
	elif Input.is_action_pressed("move_left"):
		input_vector.x = -1
		sprite.flip_h = false
		
	if Input.is_action_pressed("move_down"):
		input_vector.y = 1
	elif Input.is_action_pressed("move_up"):
		input_vector.y = -1
	
	if Input.is_action_just_pressed("interact_dodgeball"):
		_pickup_ball()
	if held_ball:
		if Input.is_action_just_pressed("aim"):
			_start_aim()
		elif Input.is_action_just_released("aim"):
			_throw_ball(held_ball)
	input_vector = input_vector.normalized()
	#Dramatically reduces the velocity when switching directions
	if sign(velocity.x) != sign(input_vector.x) and input_vector.x != 0:
		velocity.x *= 0.77
	if sign(velocity.y) != sign(input_vector.y) and input_vector.y != 0:
		velocity.y *= 0.77
	
func _snap_mouse_to_circle(center: Vector2, radius: float):
	var angle_to_pseudo_mouse: float = center.angle_to_point(pseudo_mouse_pos)
	var snapped_x: float = radius * cos(angle_to_pseudo_mouse)
	var snapped_y: float = radius * sin(angle_to_pseudo_mouse)
	pseudo_mouse_pos = Vector2(snapped_x, snapped_y)
	
func _physics_process(delta: float) -> void:
	_handle_input()
	var distance = Vector2.ZERO.distance_to(pseudo_mouse_pos)
	if abs(distance) > pseudo_mouse_radius:
		_snap_mouse_to_circle(Vector2.ZERO, pseudo_mouse_radius)
	
	$Sprite2D.global_position = pseudo_mouse_pos
	
	#Handles x forces
	if input_vector.x != 0.0:
		velocity.x = move_toward(velocity.x, MAX_SPEED * input_vector.x, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
	#Handles y forces
	if input_vector.y != 0.0:
		velocity.y = move_toward(velocity.y, MAX_SPEED * input_vector.y, ACCEL * delta)
	else:
		velocity.y = move_toward(velocity.y, 0.0, FRICTION * delta)
	if is_aiming:
		_aim_throw(delta)
	
	move_and_slide()


func _on_ball_pickup_radius_body_entered(body: Node2D) -> void:
	body.add_to_group("InteractableBalls")

func _on_ball_pickup_radius_body_exited(body: Node2D) -> void:
	body.remove_from_group("InteractableBalls")
