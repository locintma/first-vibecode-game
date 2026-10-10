extends Control
class_name BakingUI

signal baked(recipe_name: String, quality: String)
signal closed

const BadgePillScript = preload("res://scripts/ui/badge_pill.gd")
const FoodSpriteScript = preload("res://scripts/ui/food_sprite.gd")

var recipes: Array[Dictionary] = [
	{
		"name": "Steaming Pho Bo", "desc": "Rich spiced broth with rice noodles & herbs",
		"cook_time": 1.2, "dish": FoodSpriteScript.Dish.PHO_BO,
		"ingredients": [
			{"name": "Broth", "have": 2, "need": 2},
			{"name": "Noodles", "have": 3, "need": 2},
			{"name": "Herbs", "have": 1, "need": 1}
		]
	},
	{
		"name": "Crispy Banh Mi", "desc": "Crispy golden baguette with pate & pickles",
		"cook_time": 1.0, "dish": FoodSpriteScript.Dish.BANH_MI,
		"ingredients": [
			{"name": "Baguette", "have": 2, "need": 2},
			{"name": "Pate", "have": 1, "need": 1},
			{"name": "Pickles", "have": 2, "need": 1}
		]
	},
	{
		"name": "Warm Ca Phe Trung", "desc": "Sweet velvety whipped egg cream coffee",
		"cook_time": 0.8, "dish": FoodSpriteScript.Dish.CA_PHE_TRUNG,
		"ingredients": [
			{"name": "Coffee", "have": 2, "need": 2},
			{"name": "Eggs", "have": 1, "need": 1},
			{"name": "Milk", "have": 0, "need": 1}
		]
	}
]

var selected_index: int = 1 # Default Banh Mi
var _baking: bool = false

@onready var backdrop: ColorRect = $Backdrop
@onready var title_label: Label = $Panel/VBox/Header/Title
@onready var recipe_desc: Label = $Panel/VBox/RecipeDesc
@onready var badge_row: HBoxContainer = $Panel/VBox/BadgeRow
@onready var bake_button: Button = $Panel/VBox/BakeButton
@onready var close_button: Button = $Panel/VBox/Header/CloseButton
@onready var done_button: Button = $Panel/VBox/DoneButton
@onready var progress_bar: ProgressBar = $Panel/VBox/ProgressBar
@onready var status_label: Label = $Panel/VBox/StatusLabel

@onready var btn_pho: Button = $Panel/VBox/RecipeList/BtnPho
@onready var btn_banh_mi: Button = $Panel/VBox/RecipeList/BtnBanhMi
@onready var btn_ca_phe: Button = $Panel/VBox/RecipeList/BtnCaPhe

func _ready() -> void:
	if backdrop:
		backdrop.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_on_close_pressed()
		)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if done_button:
		done_button.pressed.connect(_on_close_pressed)
	if bake_button:
		bake_button.pressed.connect(_on_bake_pressed)
	if btn_pho:
		btn_pho.pressed.connect(func(): select_recipe(0))
	if btn_banh_mi:
		btn_banh_mi.pressed.connect(func(): select_recipe(1))
	if btn_ca_phe:
		btn_ca_phe.pressed.connect(func(): select_recipe(2))
	update_recipe_display()

func select_recipe(idx: int) -> void:
	if _baking:
		return
	selected_index = clamp(idx, 0, recipes.size() - 1)
	update_recipe_display()

func update_recipe_display() -> void:
	var r: Dictionary = recipes[selected_index]
	if recipe_desc:
		recipe_desc.text = "%s\n%s" % [r["name"], r["desc"]]
	for i in range(recipes.size()):
		var btn: Button = [btn_pho, btn_banh_mi, btn_ca_phe][i]
		if btn:
			btn.button_pressed = (i == selected_index)
			btn.modulate = Color(1, 1, 1) if i == selected_index else Color(0.86, 0.84, 0.82)
	if status_label and not _baking:
		status_label.text = "Choose a recipe and bake!"
	refresh_badges()

## Ingredient readiness as mint-green check pills instead of raw "5/1" text.
func refresh_badges() -> void:
	if not badge_row:
		return
	var r: Dictionary = recipes[selected_index]
	for child in badge_row.get_children():
		badge_row.remove_child(child)
		child.queue_free()
	for ing in r["ingredients"]:
		var have: int = ing["have"]
		var need: int = ing["need"]
		var ready: bool = have >= need
		var pill: PanelContainer = BadgePillScript.new()
		badge_row.add_child(pill)
		pill.setup("%s %d/%d" % [ing["name"], mini(have, need), need], ready)

func _on_bake_pressed() -> void:
	if _baking:
		return
	var r: Dictionary = recipes[selected_index]
	_baking = true
	bake_button.disabled = true
	status_label.text = "Sizzling & baking..."
	progress_bar.value = 0

	var tween = create_tween()
	tween.tween_property(progress_bar, "value", 100.0, r["cook_time"])
	tween.tween_callback(func():
		var res = bake_recipe(r["name"])
		_show_result_pill(res["quality"])
		bake_button.disabled = false
		_baking = false
	)

## Completion swaps the raw status string for a mint-green check pill.
func _show_result_pill(quality: String) -> void:
	if not badge_row:
		return
	refresh_badges()
	var pill: PanelContainer = BadgePillScript.new()
	badge_row.add_child(pill)
	pill.setup("Baked %s" % quality, true)
	if status_label:
		status_label.text = ""
	if bake_button:
		bake_button.modulate = Color(1.18, 1.14, 0.92)
		var t := create_tween()
		t.tween_property(bake_button, "modulate", Color(1, 1, 1), 0.45).set_trans(Tween.TRANS_QUAD)

func bake_recipe(recipe_name: String) -> Dictionary:
	var quality = "Perfect!"
	baked.emit(recipe_name, quality)
	return {"recipe": recipe_name, "quality": quality}

func _on_close_pressed() -> void:
	closed.emit()
	visible = false