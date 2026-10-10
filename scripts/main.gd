extends Node2D
class_name MainGame

## Cozy Haven Room & Core Game Loop
## Implements Muse Spark haven aesthetics and Nemotron 3 Ultra save invariants

@onready var critter: Critter = $Critter
@onready var toast_container: VBoxContainer = $CanvasLayer/ToastContainer
@onready var sunbeam_particles: CPUParticles2D = $SunbeamParticles

const SAVE_PATH: String = "user://haven_save.json"
const SAVE_TEMP_PATH: String = "user://haven_save.json.tmp"

func _ready() -> void:
	setup_sunbeams()
	setup_safe_zone_toasts()

func setup_sunbeams() -> void:
	if sunbeam_particles:
		# Translucent amber dust motes: 1-3px, alpha 0.12-0.25, diagonal drift 2-8px/s
		sunbeam_particles.amount = 24
		sunbeam_particles.lifetime = 8.0
		sunbeam_particles.direction = Vector2(0.6, 0.8)
		sunbeam_particles.initial_velocity_min = 2.0
		sunbeam_particles.initial_velocity_max = 8.0
		sunbeam_particles.color = Color(0.96, 0.78, 0.43, 0.20) # Amber #F6C86E with 0.2 alpha

## Fledge Alpha UX: Anchored toast banners outside the critter safe zone
func setup_safe_zone_toasts() -> void:
	if toast_container:
		# Anchored to top-right viewport edge with 12px margin
		toast_container.anchor_left = 1.0
		toast_container.anchor_right = 1.0
		toast_container.offset_left = -260
		toast_container.offset_right = -12
		toast_container.offset_top = 16

func show_toast(message: String) -> void:
	var toast := PanelContainer.new()
	var label := Label.new()
	label.text = message
	toast.add_child(label)
	toast_container.add_child(toast)
	
	# Fade out after 2.5s
	var tween: Tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_property(toast, "modulate:a", 0.0, 0.4)
	tween.tween_callback(toast.queue_free)

## Nemotron 3 Ultra: POSIX-compliant atomic save write
func save_game_atomic(data: Dictionary) -> bool:
	var json_str: String = JSON.stringify(data, "\t")
	var file := FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(json_str)
	file.flush()
	file.close()
	
	# Atomic rename prevents data corruption during crash
	var dir := DirAccess.open("user://")
	if dir:
		var err := dir.rename(SAVE_TEMP_PATH, SAVE_PATH)
		return err == OK
	return false
