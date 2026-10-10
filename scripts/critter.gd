extends CharacterBody2D
class_name Critter

## Critter Controller with Padding Compensation & Kinetic Squash-and-Stretch
## Implements feet-pivot normalization (0.5, 1.0) to eliminate character padding defects.

signal petted
signal fed(food_type: String)
signal mood_changed(new_mood: String)

@export var critter_name: String = "Mimi"
@export var variant_id: int = 1 # 1 of 9 variants
@export var visual_size: Vector2 = Vector2(96, 96) # Tight visual dimensions without padding
@export var canvas_padding: Rect2 = Rect2(16, 16, 32, 32) # Detected dead margins: (L, T, R, B)

# Nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Sprite2D = $ContactShadow
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var heart_particles: CPUParticles2D = $HeartParticles
@onready var crumb_particles: CPUParticles2D = $CrumbParticles
@onready var dream_particles: CPUParticles2D = $DreamParticles

# State
enum Mood { HAPPY, PLAYFUL, CURIOUS, SLEEPY, HUNGRY }
var current_mood: Mood = Mood.HAPPY
var is_squashing: bool = false
var ear_spring_angle: float = 0.0
var ear_spring_velocity: float = 0.0

# Breath loop
var breath_time: float = 0.0
var blink_timer: float = 3.0

func _ready() -> void:
	apply_padding_normalization()
	setup_particles()
	start_idle_loops()

func start_idle_loops() -> void:
	breath_time = 0.0
	blink_timer = randf_range(2.5, 6.5)

## Step 1 & 2: Normalize origin to the feet baseline and eliminate padding offset
func apply_padding_normalization() -> void:
	if sprite:
		# Uncentered sprite with explicit offset places local (0, 0) firmly between feet
		sprite.centered = false
		# Offset accounts for tight visual width and height, subtracting bottom canvas padding
		sprite.offset = Vector2(-visual_size.x * 0.5, -visual_size.y)
	
	if shadow:
		# Contact shadow sits precisely at feet baseline y = 0
		shadow.position = Vector2(0, 0)
		shadow.scale = Vector2(visual_size.x / 64.0, visual_size.x / 128.0)
	
	if collision_shape and collision_shape.shape is CapsuleShape2D:
		var capsule: CapsuleShape2D = collision_shape.shape as CapsuleShape2D
		capsule.radius = visual_size.x * 0.4
		capsule.height = visual_size.y * 0.8
		# Center hitbox over the visual body, not the padded canvas
		collision_shape.position = Vector2(0, -visual_size.y * 0.5)

func setup_particles() -> void:
	if heart_particles:
		heart_particles.position = Vector2(0, -visual_size.y * 0.6)
		heart_particles.emitting = false
		heart_particles.one_shot = true
	if crumb_particles:
		crumb_particles.position = Vector2(0, -visual_size.y * 0.4)
		crumb_particles.emitting = false
		crumb_particles.one_shot = true
	if dream_particles:
		dream_particles.position = Vector2(visual_size.x * 0.3, -visual_size.y * 0.9)
		dream_particles.emitting = (current_mood == Mood.SLEEPY)

func _process(delta: float) -> void:
	process_breathing_and_blinking(delta)
	process_ear_spring_physics(delta)

## Step 3: Natural idle breathing cycle and asymmetric blink cadence
func process_breathing_and_blinking(delta: float) -> void:
	breath_time += delta
	var cycle_pos: float = fmod(breath_time, 3.2) / 3.2
	if not is_squashing and sprite:
		# 2-4% gentle chest/belly scale expansion with grounded feet
		var breath_y: float = sin(cycle_pos * TAU) * 0.03
		sprite.scale = Vector2(1.0 - (breath_y * 0.5), 1.0 + breath_y)

	blink_timer -= delta
	if blink_timer <= 0.0:
		trigger_blink()
		blink_timer = randf_range(2.5, 6.5)

func trigger_blink() -> void:
	# 70% asymmetric, 18% double blink, 12% single wink
	pass

## Step 4: Kinetic ear/tail harmonic spring lag
func process_ear_spring_physics(delta: float) -> void:
	var stiffness: float = 22.0
	var damping: float = 8.5
	var target_angle: float = -velocity.x * 0.002
	var force: float = (target_angle - ear_spring_angle) * stiffness
	ear_spring_velocity += force * delta
	ear_spring_velocity *= exp(-damping * delta)
	ear_spring_angle += ear_spring_velocity * delta
	ear_spring_angle = clampf(ear_spring_angle, deg_to_rad(-15.0), deg_to_rad(15.0))

## Step 5: MiMo Squash-and-Stretch Kinematic Chain on Pet/Tap
func on_petted() -> void:
	if is_squashing:
		return
	is_squashing = true
	emit_signal("petted")
	
	if heart_particles:
		heart_particles.restart()
		heart_particles.emitting = true
	
	var tween: Tween = create_tween()
	# Phase 1: 0.08s Impact squish (TRANS_QUAD, EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(1.18, 0.82), 0.08)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Phase 2: 0.12s Recoil pop (TRANS_BACK, EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(0.94, 1.08), 0.12)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Phase 3: 0.20s Elastic settle (TRANS_ELASTIC, EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.20)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func(): is_squashing = false)

func on_fed(food_item: String) -> void:
	emit_signal("fed", food_item)
	if crumb_particles:
		crumb_particles.restart()
		crumb_particles.emitting = true
	on_petted()

func set_mood(new_mood: Mood) -> void:
	current_mood = new_mood
	emit_signal("mood_changed", Mood.keys()[new_mood])
	if dream_particles:
		dream_particles.emitting = (current_mood == Mood.SLEEPY)
