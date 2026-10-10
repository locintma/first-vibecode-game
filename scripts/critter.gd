extends Node2D
class_name Critter

signal petted(mood_delta: float)
signal fed(food_name: String, hunger_delta: float)
signal mood_state_changed(state: String)

@export var critter_name: String = "Capy"
@export var mood: float = 100.0 # 0.0 to 100.0
@export var hunger: float = 0.0 # 0.0 to 100.0

var personality_state: String = "Thrilled & Affectionate"

func _init() -> void:
	update_state()

func _ready() -> void:
	update_state()

func pet() -> void:
	mood = clamp(mood + 10.0, 0.0, 100.0)
	petted.emit(10.0)
	update_state()
	play_squash_and_stretch()

func feed(food_name: String) -> void:
	hunger = clamp(hunger - 20.0, 0.0, 100.0)
	mood = clamp(mood + 15.0, 0.0, 100.0)
	fed.emit(food_name, 20.0)
	update_state()
	play_squash_and_stretch()

func update_state() -> void:
	if mood > 80.0:
		personality_state = "Thrilled & Affectionate"
	elif mood > 40.0:
		personality_state = "Cozy & Relaxed"
	else:
		personality_state = "Sleepy & Needy"
	mood_state_changed.emit(personality_state)

# MiMo Kinematics: Snappy squash, spring pop, and guaranteed Vector2.ONE settle
func play_squash_and_stretch() -> void:
	var tween = create_tween()
	if tween:
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector2(1.15, 0.85), 0.08)
		tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.1)
		tween.tween_property(self, "scale", Vector2.ONE, 0.1)
