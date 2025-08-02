extends CharacterBody2D
class_name DodgeBall

@export var GRAVITY: float = 600
@export var FRICTION: float = 800
var is_being_held: bool = false
var airborne: bool = false
var holder: Node2D = null
var ground_line_direction: Vector2 = Vector2(-1, -1)
var ground_line_offset: Vector2 = Vector2(0, 50)
const hand_offset: Vector2 = Vector2(-4, 7)
var air_time: float = 0
var bounced: bool = false
var wall_bounced: bool = false
var bounce_1_vel: float = -150
var bounce_2_vel: float = -75
var bounce_3_vel: float = -40
var current_bounce: int = 0
var throw_dir: Vector2 = Vector2.ZERO
func project_onto_line(pos: Vector2, origin: Vector2, dir: Vector2) -> Vector2:
	var relative: Vector2 = pos - origin
	var scalar: float = (relative.dot(dir)) / dir.length_squared()
	return origin + dir * scalar
	
func handle_pickup(entity: Node2D) -> void:
	if is_being_held:
		return
	holder = entity
	global_position = holder.global_position + hand_offset
	is_being_held = true
	z_index = holder.z_index + 1
	airborne = false
	current_bounce = 0
func _spin(direction: float, rotation_force: float, delta: float):
	rotation_degrees += direction * rotation_force * delta
	
func apply_throw_force(direction: Vector2 = Vector2(1, 1), force: float = 100.0) -> void:
	var force_vector: Vector2= direction * force
	velocity = force_vector
	is_being_held = false
	airborne = true
	holder = null
	throw_dir = force_vector
	
func _physics_process(delta: float) -> void:
	if is_being_held and holder:
		global_position = holder.global_position + hand_offset
	var collision = move_and_collide(velocity * delta)
	#var normal = collision.get_normal()
	var wall_normal: Vector2 = Vector2.ZERO
	if collision:
		wall_normal = get_wall_normal()
		
	if wall_normal != Vector2.ZERO and collision:
		if not wall_bounced:
			match wall_normal * -1:
				Vector2.LEFT:
					velocity.x *= -0.4
				Vector2.RIGHT:
					velocity.x *= -0.4
				Vector2.UP:
					velocity.y *= -0.6
				Vector2.DOWN: 
					velocity.y *= -0.6
			wall_bounced = true
	else:
		wall_bounced = false
	if airborne:
		velocity.y += GRAVITY * delta
		
		var projection: Vector2 = project_onto_line(global_position, ground_line_offset, ground_line_direction)
		var distance = projection.distance_to(global_position)
		#print(distance)
		if distance < 10 :
			if not bounced:
				if current_bounce == 0:
					velocity.y = bounce_1_vel
				elif current_bounce == 1:
					velocity.y = bounce_2_vel
				elif current_bounce == 2:
					velocity.y = bounce_3_vel
				else:
					airborne = false
					
				if sign(throw_dir.y) == 1 and throw_dir.y != 0:
					velocity.y *= 0.1
				current_bounce += 1
				velocity.x *= 0.41
				bounced = true
			elif global_position.y > projection.y:
				airborne = false
		else:
			bounced = false
		#$Sprite2D.global_position.x = ground_x
		_spin(1, velocity.x * 5, delta)
		air_time += delta
	else:
		velocity.x = move_toward(velocity.x, 0.0, delta * FRICTION)
		velocity.y = 0
		current_bounce = 0
		_spin(1, velocity.x * 5, delta)
		air_time = 0

	move_and_slide()
