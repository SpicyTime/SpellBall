extends Area2D
class_name HurtBox
@export var health_node: Node2D = null
signal received_damage(amount: int)
func _on_area_entered(area: Area2D) -> void:
	if area is HitBox:
		var hitbox: HitBox = area as HitBox
		health_node.set_health(health_node.health - hitbox.damage)
		received_damage.emit(hitbox.damage)
