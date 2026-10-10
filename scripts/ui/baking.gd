extends Control
class_name BakingUI

signal baked(recipe_name: String, quality: String)

var recipes: Array[Dictionary] = [
	{"name": "Steaming Pho Bo", "cook_time": 2.0, "ready": true, "type": "simmer"},
	{"name": "Crispy Banh Mi", "cook_time": 1.5, "ready": true, "type": "crunch"},
	{"name": "Warm Ca Phe Trung", "cook_time": 1.0, "ready": true, "type": "froth"}
]

@onready var bake_button: Button = $VBoxContainer/BakeButton

func _ready() -> void:
	if bake_button:
		bake_button.pressed.connect(_on_bake_pressed)

func _on_bake_pressed() -> void:
	bake_recipe("Crispy Banh Mi")

# Big Pickle & Ling feedback: distinct cooking feel and quality rating
func bake_recipe(recipe_name: String) -> Dictionary:
	var quality = "Perfect!"
	baked.emit(recipe_name, quality)
	return {"recipe": recipe_name, "quality": quality}
