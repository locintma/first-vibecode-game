extends Control
class_name BakingUI

signal baked(recipe_name: String)

var recipes: Array[Dictionary] = [
	{"name": "Steaming Pho Bo", "ready": true},
	{"name": "Crispy Banh Mi", "ready": true},
	{"name": "Warm Ca Phe Trung", "ready": true}
]

@onready var bake_button: Button = $VBoxContainer/BakeButton

func _ready() -> void:
	if bake_button:
		bake_button.pressed.connect(_on_bake_pressed)

func _on_bake_pressed() -> void:
	bake_recipe("Crispy Banh Mi")

func bake_recipe(recipe_name: String) -> void:
	baked.emit(recipe_name)
