extends Node2D

func _draw() -> void:
	var pink = Color(1.0, 0.42, 0.58, 0.95)
	draw_circle(Vector2(-5, -4), 5.0, pink)
	draw_circle(Vector2(5, -4), 5.0, pink)
	var pts = PackedVector2Array([
		Vector2(-9, -2),
		Vector2(9, -2),
		Vector2(0, 9)
	])
	draw_colored_polygon(pts, pink)
