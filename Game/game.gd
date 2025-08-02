extends Node2D
@onready var dodgeball: DodgeBall = $Dodgeball


func _ready() -> void:
	queue_redraw()
	
func _process(delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	var offset: Vector2 = dodgeball.ground_line_offset
	draw_line(dodgeball.ground_line_direction * 500 + offset, dodgeball.ground_line_direction * -500 + offset, Color(255, 0, 0), 1)
