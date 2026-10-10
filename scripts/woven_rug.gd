extends Node2D
class_name WovenRug

@export var radius_x: float = 132.0
@export var radius_y: float = 78.0

func _draw() -> void:
	var cx := 0.0
	var cy := 6.0
	draw_ring(cx, cy, radius_x, radius_y, Color(0.45, 0.33, 0.22, 0.35), 5.0)
	draw_ring(cx, cy, radius_x, radius_y, Color(0.78, 0.65, 0.48, 1.0), 4.0)
	draw_ring(cx, cy, radius_x * 0.88, radius_y * 0.88, Color(0.86, 0.74, 0.56, 1.0), 3.0)

	var strands := 48
	for i in range(strands):
		var th := i * (TAU / strands)
		var c := cos(th)
		var s := sin(th)
		var inner := Vector2(cx + c * radius_x * 0.44, cy + s * radius_y * 0.44)
		var outer := Vector2(cx + c * radius_x * 0.84, cy + s * radius_y * 0.84)
		draw_line(inner, outer, Color(0.72, 0.60, 0.44, 0.55), 1.5)

	for i in range(24):
		var th := i * (TAU / 24) + TAU / 48.0
		var c := cos(th)
		var s := sin(th)
		var inner := Vector2(cx + c * radius_x * 0.50, cy + s * radius_y * 0.50)
		var outer := Vector2(cx + c * radius_x * 0.80, cy + s * radius_y * 0.80)
		draw_line(inner, outer, Color(0.90, 0.80, 0.63, 0.75), 1.5)

	draw_ring(cx, cy, radius_x * 0.40, radius_y * 0.40, Color(0.83, 0.44, 0.36, 1.0), 6.0)
	draw_ring(cx, cy, radius_x * 0.24, radius_y * 0.24, Color(0.92, 0.72, 0.52, 1.0), 5.0)
	draw_ring(cx, cy, radius_x * 0.11, radius_y * 0.11, Color(0.83, 0.44, 0.36, 1.0), 4.0)

	_draw_fringe(cx, cy)

func draw_ring(cx: float, cy: float, rx: float, ry: float, col: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var n := 48
	for i in range(n):
		var th := i * (TAU / n)
		pts.append(Vector2(cx + cos(th) * rx, cy + sin(th) * ry))
	draw_polyline(pts, col, width, true)

func _draw_fringe(cx: float, cy: float) -> void:
	var count := 40
	for i in range(count):
		var th := i * (TAU / count)
		var c := cos(th)
		var s := sin(th)
		var base := Vector2(cx + c * radius_x, cy + s * radius_y)
		var tip := Vector2(cx + c * (radius_x + 9.0), cy + s * (radius_y + 6.0))
		draw_line(base, tip, Color(0.90, 0.82, 0.66, 0.9), 2.0)
