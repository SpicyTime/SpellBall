extends CharacterBody2D
@export var FRICTION: float = 0.0
@export var ACCEL: float = 0.0
@export var MAX_SPEED: float = 0.0
var input_vector: Vector2 = Vector2.ZERO

func _handle_input():
	#The input vectors main purpose is to be mutliplied by the speed to move in the desired direction
	input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_vector.x = 1
	elif Input.is_action_pressed("move_left"):
		input_vector.x = -1
	if Input.is_action_pressed("move_down"):
		input_vector.y = 1
	elif Input.is_action_pressed("move_up"):
		input_vector.y = -1
	
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
