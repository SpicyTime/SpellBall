extends CharacterBody2D
@export var FRICTION: float = 0.0
@export var ACCEL: float = 0.0
@export var MAX_SPEED: float = 0.0
@onready var sprite: Sprite2D = $Sprite2D

var input_vector: Vector2 = Vector2.ZERO
var held_ball: DodgeBall = null
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
func _interact_with_ball():
	if held_ball:
		_throw_ball(held_ball)
	else:
		_pickup_ball()
func _pickup_ball() -> void:
	var closest_ball = _get_nearest_pickupable_ball()
	if closest_ball: 
		closest_ball.handle_pickup(self)
		held_ball = closest_ball
		
func _throw_ball(ball: DodgeBall) -> void:
	ball.apply_throw_force(Vector2(get_facing_direction(), -1), 200)
	held_ball = null
	
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
		_interact_with_ball()
		
	input_vector = input_vector.normalized()
	#Dramatically reduces the velocity when switching directions
	if sign(velocity.x) != sign(input_vector.x) and input_vector.x != 0:
		velocity.x *= 0.77
	if sign(velocity.y) != sign(input_vector.y) and input_vector.y != 0:
		velocity.y *= 0.77
	
		
func _physics_process(delta: float) -> void:
	_handle_input()
	
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
	move_and_slide()


func _on_ball_pickup_radius_body_entered(body: Node2D) -> void:
	body.add_to_group("InteractableBalls")

func _on_ball_pickup_radius_body_exited(body: Node2D) -> void:
	body.remove_from_group("InteractableBalls")
