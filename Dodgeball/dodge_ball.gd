extends CharacterBody2D
class_name DodgeBall

@export var GRAVITY: float = 980
var floor_position: float = 0.0
var is_being_held: bool = false
var airborne: bool = false
var holder: Node2D = null
const hand_offset: Vector2 = Vector2(-4, 7)

func handle_pickup(entity: Node2D) -> void:
	if is_being_held:
		return
	holder = entity
	global_position = holder.global_position + hand_offset
	is_being_held = true
	z_index = holder.z_index + 1
	
func apply_throw_force(direction: Vector2 = Vector2(1, 1), force: float = 100) -> void:
	var length: Vector2 = direction * force 
	var vertex: Vector2 = length + global_position
	var end_pos: Vector2 = Vector2(global_position.x + length.x, floor_position)
	floor_position = holder.global_position.y + 15
	velocity = length
	airborne = true
	is_being_held = false
	holder = null
	
	
func _physics_process(delta: float) -> void:
	if is_being_held and holder:
		global_position = holder.global_position + hand_offset
	if airborne:
		velocity.y += GRAVITY * delta
		var distance_to_floor: float = global_position.y - floor_position
		if abs(distance_to_floor) < 2:
			airborne = false
			velocity = Vector2.ZERO
	#var distance_to_floor_pos = global_position.distance_to(floor_position)
	move_and_slide()
