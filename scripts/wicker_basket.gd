extends Node2D
class_name WickerBasket

const RIM_Y := -44.0
const BASE_Y := 0.0
const TOP_HALF := 32.0
const BASE_HALF := 23.0

func _draw() -> void:
	draw_ellipse(Vector2(0, 2), 28, 8, Color(0.42, 0.30, 0.20, 0.30))
	_draw_body()
	_draw_weave()
	_draw_rim()
	_draw_handle()
	_draw_contents()

func _half_at(y: float) -> float:
	var t := clampf((y - BASE_Y) / (RIM_Y - BASE_Y), 0.0, 1.0)
	return lerpf(BASE_HALF, TOP_HALF, t)

func _draw_body() -> void:
	var steps := 12
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	for i in range(steps + 1):
		var y := lerpf(BASE_Y, RIM_Y, float(i) / steps)
		var h := _half_at(y)
		left.append(Vector2(-h, y))
		right.append(Vector2(h, y))
	right.reverse()
	draw_colored_polygon(left + right, Color(0.66, 0.50, 0.33, 1.0))

func _draw_weave() -> void:
	var rows := 7
	for i in range(rows + 1):
		var y := lerpf(BASE_Y + 3.0, RIM_Y - 2.0, float(i) / rows)
		var h := _half_at(y)
		draw_line(Vector2(-h, y), Vector2(h, y), Color(0.52, 0.38, 0.24, 0.85), 2.0)

	var stakes := 11
	for i in range(stakes + 1):
		var x := lerpf(-BASE_HALF + 1.0, BASE_HALF - 1.0, float(i) / stakes)
		var frac := (x + BASE_HALF) / (TOP_HALF - BASE_HALF)
		var x_top := lerpf(-_half_at(RIM_Y), _half_at(RIM_Y), clampf(frac, 0.0, 1.0))
		draw_line(Vector2(x, BASE_Y + 2.0), Vector2(x_top, RIM_Y - 1.0), Color(0.78, 0.62, 0.42, 0.7), 1.5)

func _draw_rim() -> void:
	draw_ellipse(Vector2(0, RIM_Y), TOP_HALF, 8.0, Color(0.80, 0.64, 0.44, 1.0))
	draw_ellipse(Vector2(0, RIM_Y + 1.0), TOP_HALF - 4.0, 6.0, Color(0.48, 0.34, 0.22, 1.0))

func _draw_handle() -> void:
	var pts := PackedVector2Array()
	for i in range(17):
		var th := lerpf(PI, TAU, float(i) / 16.0)
		pts.append(Vector2(cos(th) * (TOP_HALF - 2.0), RIM_Y + sin(th) * 26.0))
	draw_polyline(pts, Color(0.74, 0.58, 0.40, 1.0), 4.0, true)

func _draw_contents() -> void:
	draw_ellipse(Vector2(-8, RIM_Y - 4.0), 15, 9.0, Color(0.95, 0.88, 0.82, 1.0))
	draw_ellipse(Vector2(-9, RIM_Y - 6.0), 11, 6.0, Color(0.99, 0.94, 0.90, 1.0))
	draw_circle(Vector2(11, RIM_Y - 5.0), 8.0, Color(0.87, 0.62, 0.52, 1.0))
	draw_circle(Vector2(10, RIM_Y - 7.0), 3.0, Color(0.95, 0.78, 0.72, 1.0))
	draw_line(Vector2(-8, RIM_Y - 12.0), Vector2(6, RIM_Y - 20.0), Color(0.85, 0.74, 0.60, 1.0), 2.0)

func draw_ellipse(pos: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var n := 32
	for i in range(n):
		var th := i * (TAU / n)
		pts.append(pos + Vector2(cos(th) * rx, sin(th) * ry))
	draw_colored_polygon(pts, col)
