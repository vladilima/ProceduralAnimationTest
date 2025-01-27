extends Node2D

@onready var dot_1 = $"CollisionShape2D/Dot 1"
@onready var dot_2 = $"CollisionShape2D/Dot 2"
@onready var Arrow = $CollisionShape2D/Arrow

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	Arrow.look_at(mouse_pos)
	Arrow.rotate(-PI / 2)
	
	var angle : float = Vector2(mouse_pos- Arrow.global_position).angle()
	print("Θ: ", angle)
	
	var arrow_point_x = 100 * cos(angle)
	var arrow_point_y = 100 * sin(angle)
	print("Arrow Point: ", Vector2(arrow_point_x, arrow_point_y))
	
	var left_side_x = 100 * cos(angle - PI / 2)
	var left_side_y = 100 * sin(angle - PI / 2)
	dot_1.position = lerp(dot_1.position, Vector2(left_side_x, left_side_y), .5)
	print("Left Side: ", Vector2(left_side_x, left_side_y))
	
	var right_side_x = 100 * cos(angle + PI / 2)
	var right_side_y = 100 * sin(angle + PI / 2)
	dot_2.position = lerp(dot_2.position, Vector2(right_side_x, right_side_y), .25)
	print("Right Side: ", Vector2(right_side_x, right_side_y))
