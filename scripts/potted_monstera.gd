extends Node2D
class_name PottedMonstera

const LEAF_BASE_Y := -46.0

var _stems: Array[Vector2] = [
	Vector2(-34, -118), Vector2(-6, -150), Vector2(28, -122),
	Vector2(44, -88), Vector2(-48, -92),
]
var _swings: Array[float] = [-6.0, 2.0, 6.0, 3.0, -3.0]
var _angles: Array[float] = [-0.75, -0.10, 0.55, 1.00, -1.30]
var _lengths: Array[float] = [46.0, 54.0, 48.0, 38.0, 40.0]
var _widths: Array[float] = [26.0, 28.0, 25.0, 21.0, 22.0]
var _shades: Array[Color] = [
	Color(0.30, 0.54, 0.33), Color(0.24, 0.47, 0.29),
	Color(0.34, 0.58, 0.35), Color(0.22, 0.44, 0.28),
	Color(0.27, 0.50, 0.31),
]

func _draw() -> void:
	draw_ellipse(Vector2(0, 2), 30, 9, Color(0.42, 0.30, 0.20, 0.28))
	_draw_pot()
	_draw_stems()
	_draw_leaves()

func _draw_pot() -> void:
	var pts := PackedVector2Array([
		Vector2(-26, LEAF_BASE_Y), Vector2(26, LEAF_BASE_Y),
		Vector2(19, 0), Vector2(-19, 0),
	])
	draw_colored_polygon(pts, Color(0.79, 0.47, 0.33, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-27, LEAF_BASE_Y - 8), Vector2(27, LEAF_BASE_Y - 8),
		Vector2(26, LEAF_BASE_Y + 2), Vector2(-26, LEAF_BASE_Y + 2),
	]), Color(0.86, 0.54, 0.38, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-23, LEAF_BASE_Y - 6), Vector2(23, LEAF_BASE_Y - 6),
		Vector2(23, LEAF_BASE_Y - 1), Vector2(-23, LEAF_BASE_Y - 1),
	]), Color(0.40, 0.28, 0.20, 1.0))
	draw_line(Vector2(-14, LEAF_BASE_Y + 10), Vector2(-15, -8), Color(0.68, 0.39, 0.27, 0.8), 3.0)
	draw_line(Vector2(13, LEAF_BASE_Y + 14), Vector2(14, -6), Color(0.68, 0.39, 0.27, 0.8), 3.0)

func _stem(leaf_base: Vector2, sway: float) -> void:
	var start := Vector2(0, LEAF_BASE_Y + 2)
	var ctrl := Vector2(leaf_base.x * 0.25 + sway, LEAF_BASE_Y - 22.0)
	var pts := PackedVector2Array()
	for i in range(13):
		var t := float(i) / 12.0
		var a := start.lerp(ctrl, t)
		var b := ctrl.lerp(leaf_base, t)
		pts.append(a.lerp(b, t))
	draw_polyline(pts, Color(0.26, 0.45, 0.28, 1.0), 4.0, true)

func _draw_stems() -> void:
	for i in range(_stems.size()):
		_stem(_stems[i], _swings[i])

func _draw_leaves() -> void:
	for i in range(_stems.size()):
		var poly := _leaf_polygon(_lengths[i], _widths[i], i)
		var rotated := PackedVector2Array()
		var ca := cos(_angles[i])
		var sa := sin(_angles[i])
		for p in poly:
			rotated.append(_stems[i] + Vector2(p.x * ca - p.y * sa, p.x * sa + p.y * ca))
		draw_colored_polygon(rotated, _shades[i])

		var midrib := PackedVector2Array()
		var reach := _lengths[i] * 0.92
		var tip := _stems[i] + Vector2(sin(_angles[i]) * reach, -cos(_angles[i]) * reach)
		midrib.append(_stems[i])
		midrib.append(tip)
		draw_polyline(midrib, Color(0.62, 0.78, 0.55, 0.55), 1.5, true)

func _leaf_polygon(length: float, width: float, seed: int) -> PackedVector2Array:
	var n := 40
	var right := PackedVector2Array()
	var left := PackedVector2Array()
	var notch_t := [0.30, 0.48, 0.66]
	for i in range(n + 1):
		var t := float(i) / n
		var w := width * pow(sin(PI * t), 0.62)
		var r := w
		var l := w
		for k in range(notch_t.size()):
			var center: float = notch_t[k]
			if absf(t - center) < 0.05:
				var falloff := 1.0 - absf(t - center) / 0.05
				var bite := 0.14 + 0.06 * float((seed + k) % 2)
				if (seed + k) % 2 == 0:
					r *= lerpf(1.0, bite, falloff)
				else:
					l *= lerpf(1.0, bite, falloff)
		var y := -t * length
		right.append(Vector2(r, y))
		left.append(Vector2(-l, y))
	left.reverse()
	return right + left

func draw_ellipse(pos: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var n := 24
	for i in range(n):
		var th := i * (TAU / n)
		pts.append(pos + Vector2(cos(th) * rx, sin(th) * ry))
	draw_colored_polygon(pts, col)
