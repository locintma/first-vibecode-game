extends Node2D
class_name Critter

signal petted
signal fed(food_name: String)

@export var critter_name: String = "Capy"
@export var mood: float = 100.0 # 0.0 to 100.0
@export var hunger: float = 0.0 # 0.0 to 100.0

var is_animating: bool = false

func _ready() -> void:
	pass

func pet() -> void:
	mood = clamp(mood + 10.0, 0.0, 100.0)
	petted.emit()
	play_squash_and_stretch()

func feed(food_name: String) -> void:
	hunger = clamp(hunger - 20.0, 0.0, 100.0)
	mood = clamp(mood + 15.0, 0.0, 100.0)
	fed.emit(food_name)
	play_squash_and_stretch()

func play_squash_and_stretch() -> void:
	var tween = create_tween()
	if tween:
		tween.tween_property(self, "scale", Vector2(1.15, 0.85), 0.1)
		tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.1)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
