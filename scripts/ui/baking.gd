extends Control
class_name BakingUI

signal baked(recipe_name: String, quality: String)
signal closed

var recipes: Array[Dictionary] = [
	{"name": "Steaming Pho Bo", "desc": "Rich spiced broth with rice noodles & herbs", "cook_time": 1.2, "icon": ""},
	{"name": "Crispy Banh Mi", "desc": "Crispy golden baguette with pate & pickles", "cook_time": 1.0, "icon": ""},
	{"name": "Warm Ca Phe Trung", "desc": "Sweet velvety whipped egg cream coffee", "cook_time": 0.8, "icon": ""}
]

var selected_index: int = 1 # Default Banh Mi

@onready var backdrop: ColorRect = $Backdrop
@onready var title_label: Label = $Panel/VBox/Header/Title
@onready var recipe_desc: Label = $Panel/VBox/RecipeDesc
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
	selected_index = clamp(idx, 0, recipes.size() - 1)
	update_recipe_display()

func update_recipe_display() -> void:
	var r = recipes[selected_index]
	if recipe_desc:
		recipe_desc.text = "%s\n%s" % [r["name"], r["desc"]]

func _on_bake_pressed() -> void:
	var r = recipes[selected_index]
	bake_button.disabled = true
	status_label.text = "Sizzling & baking..."
	progress_bar.value = 0
	
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", 100.0, r["cook_time"])
	tween.tween_callback(func():
		var res = bake_recipe(r["name"])
		status_label.text = "%s baked to %s!" % [r["name"], res["quality"]]
		bake_button.disabled = false
	)

func bake_recipe(recipe_name: String) -> Dictionary:
	var quality = "Perfect!"
	baked.emit(recipe_name, quality)
	return {"recipe": recipe_name, "quality": quality}

func _on_close_pressed() -> void:
	closed.emit()
	visible = false
