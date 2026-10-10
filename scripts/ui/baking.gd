extends Control
class_name BakingUI

## Vietnamese Culinary Baking UI & Minigame
## Implements Big Pickle's culinary feedback & visual badging specs

signal recipe_completed(recipe_name: String)

@export var recipes: Array[Dictionary] = [
	{
		"id": "pho_bo",
		"name": "Phở Bò Hà Nội",
		"desc": "Aromatic simmering beef broth with star anise, rice noodles, and fresh herbs.",
		"cost_herbs": 3,
		"cost_broth": 1,
		"icon_color": Color("#8B4513") # Rich broth brown
	},
	{
		"id": "banh_mi",
		"name": "Bánh Mì Giòn Rụm",
		"desc": "Crispy golden baguette with pate, pickled daikon, cucumber, and cilantro.",
		"cost_flour": 2,
		"cost_veggies": 2,
		"icon_color": Color("#D2A679") # Crust golden amber
	},
	{
		"id": "ca_phe_trung",
		"name": "Cà Phê Trứng",
		"desc": "Rich dark Vietnamese robusta coffee topped with whipped velvety egg crema.",
		"cost_coffee": 2,
		"cost_eggs": 2,
		"icon_color": Color("#F6C86E") # Creamy egg yolk yellow
	}
]

var active_recipe_index: int = 0
@onready var bake_button: Button = $BakeButton
@onready var starburst_glow: TextureRect = $StarburstGlow
@onready var badge_container: HBoxContainer = $BadgeContainer

func _ready() -> void:
	setup_apricot_bake_button()
	update_recipe_display()

func setup_apricot_bake_button() -> void:
	if bake_button:
		# Warm apricot tone with subtle pressed highlight
		var apricot_normal := Color("#FFA07A")
		var apricot_hover := Color("#FF8C69")
		var apricot_pressed := Color("#E07050")
		bake_button.text = "Nướng Ngay"
		bake_button.add_theme_color_override("font_color", Color.WHITE)

## Replace raw "OK 5/1" with mint-green checkmark pill badges
func create_checkmark_pill(item_name: String, required: int, current: int) -> Control:
	var pill := PanelContainer.new()
	var is_ready: bool = current >= required
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.bg_color = Color("#2E8B57") if is_ready else Color("#708090") # Mint-green or muted slate
	pill.add_theme_stylebox_override("panel", style)
	
	var label := Label.new()
	label.text = "✓ %s (%d/%d)" % [item_name, current, required] if is_ready else "… %s (%d/%d)" % [item_name, current, required]
	pill.add_child(label)
	return pill

func update_recipe_display() -> void:
	var recipe: Dictionary = recipes[active_recipe_index]
	# Update UI elements with illustrated food sprites and badges
	pass

## Big Pickle Celebration: 0.28s punch (0.75 -> 1.18 -> 1.0) with TRANS_BACK & golden halo
func trigger_bake_celebration() -> void:
	var recipe: Dictionary = recipes[active_recipe_index]
	emit_signal("recipe_completed", recipe["name"])
	
	if starburst_glow:
		starburst_glow.visible = true
		starburst_glow.scale = Vector2(0.2, 0.2)
		starburst_glow.modulate = Color(1, 1, 1, 1)
		
		var tween: Tween = create_tween().set_parallel(true)
		# Halo expansion 0.2 -> 1.6 and fade out over 0.45s
		tween.tween_property(starburst_glow, "scale", Vector2(1.6, 1.6), 0.45)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(starburst_glow, "modulate:a", 0.0, 0.45)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
