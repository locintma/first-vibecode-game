extends Node2D
class_name FairyBulbs

var GARLAND := PackedVector2Array([
	Vector2(40, 20), Vector2(130, 40), Vector2(240, 45),
	Vector2(350, 40), Vector2(440, 20),
])

var _time := 0.0

func _ready() -> void:
	_time = randf() * TAU

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	for i in range(8):
		var at := (float(i) + 0.5) / 8.0
		var anchor := _sample(at)
		var phase := _time * 2.1 + float(i) * 1.7
		var pulse := 0.82 + 0.18 * sin(phase)
		_draw_bulb(anchor, pulse)

func _sample(t: float) -> Vector2:
	var span := GARLAND.size() - 1
	var pos := clampf(t, 0.0, 0.9999) * span
	var i := int(floor(pos))
	return GARLAND[i].lerp(GARLAND[i + 1], pos - float(i))

func _draw_bulb(anchor: Vector2, pulse: float) -> void:
	var socket := anchor + Vector2(0, 4)
	var bulb := anchor + Vector2(0, 11)
	var warm := Color(1.0, 0.82, 0.48)

	draw_line(anchor, socket, Color(0.45, 0.38, 0.32, 0.9), 1.5)
	draw_circle(socket, 2.0, Color(0.62, 0.52, 0.42, 1.0))

	for i in range(4):
		var k := 1.0 - float(i) * 0.22
		draw_circle(bulb, 13.0 * k * pulse, Color(warm.r, warm.g, warm.b, 0.07 + 0.05 * pulse))

	draw_circle(bulb, 5.0, Color(warm.r, warm.g, warm.b, 0.95))
	draw_circle(bulb - Vector2(1.4, 1.6), 1.8, Color(1.0, 0.98, 0.9, 0.95 * pulse))
	draw_line(bulb + Vector2(-3.0, 3.6), bulb + Vector2(3.0, 3.6), Color(0.60, 0.50, 0.40, 0.9), 1.2)
