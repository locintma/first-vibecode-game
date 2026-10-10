extends Node2D
class_name HavenWindow

const FRAME := Rect2(0, 0, 130, 100)
const PANS := Rect2(7, 7, 116, 86)
var BEAM_DIR := Vector2(0.62, 0.78).normalized()

func _draw() -> void:
	draw_rect(FRAME, Color(0.93, 0.87, 0.78, 1.0), true)
	_draw_sky()
	_draw_frame()
	_draw_sill()
	_draw_beam()
	_draw_light_pool()

func _draw_sky() -> void:
	draw_rect(PANS, Color(0.72, 0.86, 0.94, 1.0), true)
	draw_circle(Vector2(40, 30), 15.0, Color(0.99, 0.95, 0.78, 0.9))
	draw_circle(Vector2(86, 62), 12.0, Color(0.99, 0.97, 0.92, 0.75))
	draw_circle(Vector2(22, 70), 10.0, Color(0.99, 0.97, 0.92, 0.65))

func _draw_frame() -> void:
	var mullion := Color(0.93, 0.87, 0.78, 1.0)
	draw_rect(Rect2(62, 7, 6, 86), mullion, true)
	draw_rect(Rect2(7, 47, 116, 6), mullion, true)
	draw_rect(FRAME, Color(0.84, 0.74, 0.60, 1.0), false, 3.0)

func _draw_sill() -> void:
	draw_rect(Rect2(-6, 100, 142, 9), Color(0.90, 0.82, 0.70, 1.0), true)
	draw_rect(Rect2(-6, 107, 142, 3), Color(0.72, 0.62, 0.50, 1.0), true)

func _beam_span(spread: float, reach: float) -> PackedVector2Array:
	var origin := PANS.get_center()
	var perp := Vector2(-BEAM_DIR.y, BEAM_DIR.x)
	var left := origin + perp * (PANS.size.x * 0.5 * spread)
	var right := origin - perp * (PANS.size.x * 0.5 * spread)
	var mid := BEAM_DIR * (reach * 0.5)
	var widen := 1.0 + spread * 1.6
	return PackedVector2Array([
		left, right, mid - perp * (PANS.size.x * 0.5 * widen), mid + perp * (PANS.size.x * 0.5 * widen),
	])

func _draw_beam() -> void:
	var warm := Color(1.0, 0.94, 0.74, 1.0)
	for layer in 3:
		var spread := 0.62 + 0.19 * float(layer)
		var reach := 300.0 - 22.0 * float(layer)
		var alpha := 0.055 + 0.035 * float(layer)
		draw_colored_polygon(_beam_span(spread, reach), Color(warm.r, warm.g, warm.b, alpha))

func _draw_light_pool() -> void:
	var land := PANS.get_center() + BEAM_DIR * 300.0
	var pool := Color(1.0, 0.94, 0.76, 0.22)
	for i in range(5):
		var k := 1.0 - float(i) * 0.17
		var pts := PackedVector2Array()
		for j in range(24):
			var th := j * (TAU / 24.0)
			pts.append(land + Vector2(cos(th) * 86.0 * k, sin(th) * 21.0 * k))
		draw_colored_polygon(pts, Color(pool.r, pool.g, pool.b, pool.a * 0.34))
