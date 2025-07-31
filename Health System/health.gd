extends Node
class_name Health
signal health_changed(new_value: int, node: Node2D)
signal max_health_changed(new_value: int, node: Node2D)
signal health_depleted(node: Node2D)
@export var parent: Node2D
var max_health: int : set = set_max_health
var health: int : set = set_health

func set_max_health(value: int) -> void:
	max_health = value
	max_health_changed.emit(value, parent)
	
func set_health(value: int) -> void:
	health = value
	if value > 0:
		health_changed.emit(value, parent)
	else:
		health_depleted.emit(parent)
