extends Node
class_name SoundManager

## Audio Manager with tactile feedback ripple and normalized event playback
## Recommended by Ling 3.1 Flash Free

@onready var sfx_players: Array[AudioStreamPlayer] = []
var active_ripple_tweens: Array[Tween] = []

func _ready() -> void:
	# Pre-allocate audio voice channels
	for i in range(8):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)

func play_sfx(sound_name: String, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	for player in sfx_players:
		if not player.playing:
			player.pitch_scale = pitch_scale
			player.volume_db = volume_db
			# In actual asset setup, player.stream = sound_stream
			# player.play()
			return

## Ling Flash recommendation: 3 quiet, pitch-softened radiating taps on pet
func play_petting_ripple() -> void:
	var tween: Tween = create_tween()
	# Tap 1 (pitch 1.1)
	tween.tween_callback(func(): play_sfx("pet_tap", 1.1, -4.0))
	# Tap 2 (pitch 1.15, delayed 0.07s)
	tween.tween_interval(0.07)
	tween.tween_callback(func(): play_sfx("pet_tap", 1.15, -6.0))
	# Tap 3 (pitch 1.20, delayed 0.07s)
	tween.tween_interval(0.07)
	tween.tween_callback(func(): play_sfx("pet_tap", 1.20, -8.0))

func play_food_crunch() -> void:
	play_sfx("food_crunch", randf_range(0.95, 1.05), -2.0)

func play_baking_chime() -> void:
	play_sfx("bake_starburst", 1.0, 0.0)

func play_item_collect() -> void:
	play_sfx("item_chime", randf_range(1.0, 1.1), -3.0)
