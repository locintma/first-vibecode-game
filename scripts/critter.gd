extends Node2D
class_name Critter

signal petted(mood_delta: float)
signal fed(food_name: String, hunger_delta: float)
signal mood_state_changed(state: String)

@export var critter_name: String = "Capy"
@export var mood: float = 100.0 # 0.0 to 100.0
@export var hunger: float = 0.0 # 0.0 to 100.0

var personality_state: String = "Thrilled & Affectionate"
var ear_wiggle: float = 0.0
var idle_breath: float = 1.0

func _init() -> void:
	update_state()

func _ready() -> void:
	update_state()
	start_idle_animation()

func _draw() -> void:
	# --- Procedural Stylized Capybara ---
	# Soft shadow under critter
	draw_ellipse_shape(Vector2(0, 35), 65, 20, Color(0.2, 0.15, 0.1, 0.25))

	# Main Body (Warm Golden Brown)
	var body_color = Color(0.72, 0.54, 0.36)
	var belly_color = Color(0.82, 0.65, 0.46)
	draw_ellipse_shape(Vector2(0, 5), 58, 48, body_color)
	draw_ellipse_shape(Vector2(0, 10), 44, 34, belly_color)

	# Head
	draw_ellipse_shape(Vector2(0, -32), 48, 38, body_color)

	# Snout / Muzzle
	draw_ellipse_shape(Vector2(0, -22), 34, 24, Color(0.64, 0.46, 0.30))

	# Dark Round Nose
	draw_ellipse_shape(Vector2(0, -28), 9, 6, Color(0.22, 0.15, 0.10))

	# Nostrils
	draw_circle(Vector2(-3, -27), 1.5, Color(0.12, 0.08, 0.05))
	draw_circle(Vector2(3, -27), 1.5, Color(0.12, 0.08, 0.05))

	# Rosy Blush Cheeks
	var blush = Color(1.0, 0.55, 0.55, 0.45)
	draw_circle(Vector2(-28, -20), 8, blush)
	draw_circle(Vector2(28, -20), 8, blush)

	# Glossy Catchlight Eyes
	var eye_color = Color(0.12, 0.08, 0.06)
	draw_circle(Vector2(-20, -38), 6, eye_color)
	draw_circle(Vector2(20, -38), 6, eye_color)
	# Dual specular catchlights
	draw_circle(Vector2(-18.5, -40), 2.2, Color(1, 1, 1, 0.95))
	draw_circle(Vector2(21.5, -40), 2.2, Color(1, 1, 1, 0.95))
	draw_circle(Vector2(-21.5, -36.5), 1.0, Color(1, 1, 1, 0.7))
	draw_circle(Vector2(18.5, -36.5), 1.0, Color(1, 1, 1, 0.7))

	# Cute Capybara Ears
	var ear_color = Color(0.60, 0.42, 0.28)
	var ear_inner = Color(0.85, 0.65, 0.65)
	draw_ellipse_shape(Vector2(-38, -55 + ear_wiggle), 12, 9, ear_color)
	draw_ellipse_shape(Vector2(-38, -55 + ear_wiggle), 7, 5, ear_inner)
	draw_ellipse_shape(Vector2(38, -55 - ear_wiggle), 12, 9, ear_color)
	draw_ellipse_shape(Vector2(38, -55 - ear_wiggle), 7, 5, ear_inner)

	# Tiny feet peeking out
	draw_ellipse_shape(Vector2(-30, 42), 14, 8, Color(0.55, 0.38, 0.24))
	draw_ellipse_shape(Vector2(30, 42), 14, 8, Color(0.55, 0.38, 0.24))

func draw_ellipse_shape(pos: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts = PackedVector2Array()
	var num_pts = 32
	for i in range(num_pts):
		var th = i * (TAU / num_pts)
		pts.append(pos + Vector2(cos(th) * rx, sin(th) * ry))
	draw_colored_polygon(pts, col)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = to_local(event.position)
		if local_pos.length() < 70.0:
			pet()

func pet() -> void:
	mood = clamp(mood + 10.0, 0.0, 100.0)
	petted.emit(10.0)
	update_state()
	play_squash_and_stretch()
	spawn_heart_particle()

func feed(food_name: String) -> void:
	hunger = clamp(hunger - 25.0, 0.0, 100.0)
	mood = clamp(mood + 15.0, 0.0, 100.0)
	fed.emit(food_name, 25.0)
	update_state()
	play_squash_and_stretch()
	spawn_heart_particle()

func update_state() -> void:
	if mood > 80.0:
		personality_state = "Thrilled & Affectionate"
	elif mood > 40.0:
		personality_state = "Cozy & Relaxed"
	else:
		personality_state = "Sleepy & Needy"
	mood_state_changed.emit(personality_state)

func start_idle_animation() -> void:
	var t = create_tween().set_loops()
	t.tween_property(self, "scale", Vector2(1.02, 0.98), 1.2).set_trans(Tween.TRANS_SINE)
	t.tween_property(self, "scale", Vector2(0.98, 1.02), 1.2).set_trans(Tween.TRANS_SINE)

func play_squash_and_stretch() -> void:
	var tween = create_tween()
	if tween:
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector2(1.18, 0.82), 0.08)
		tween.tween_property(self, "scale", Vector2(0.88, 1.12), 0.1)
		tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func spawn_heart_particle() -> void:
	var fx = Node2D.new()
	fx.set_script(preload("res://scripts/heart_fx.gd"))
	fx.position = Vector2(randf_range(-20, 20), -70)
	add_child(fx)
	var t = create_tween()
	t.tween_property(fx, "position:y", fx.position.y - 45, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(fx, "scale", Vector2(1.3, 1.3), 0.8)
	t.parallel().tween_property(fx, "modulate:a", 0.0, 0.8)
	t.tween_callback(fx.queue_free)
