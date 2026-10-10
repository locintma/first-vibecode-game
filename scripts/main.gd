extends Node2D

@onready var critter: Critter = $Critter
@onready var toast_banner: Label = $HUD/ToastBanner
@onready var toast_backdrop: Panel = $HUD/ToastBackdrop
@onready var mood_bar: ProgressBar = $HUD/TopBar/HBox/StatsVBox/MoodHBox/MoodBar
@onready var hunger_bar: ProgressBar = $HUD/TopBar/HBox/StatsVBox/HungerHBox/HungerBar
@onready var coins_label: Label = $HUD/TopBar/HBox/CoinsLabel
@onready var state_label: Label = $HUD/TopBar/HBox/StatsVBox/StateLabel

@onready var pet_button: Button = $HUD/BottomBar/PetButton
@onready var bake_button: Button = $HUD/BottomBar/BakeButton
@onready var walk_button: Button = $HUD/BottomBar/WalkButton

@onready var baking_ui: BakingUI = $Overlays/BakingUI
@onready var gathering_walk: GatheringWalk = $Overlays/GatheringWalk

var coins: int = 100
var inventory: Array[String] = ["Crispy Banh Mi"]

var _toast_tween: Tween

func _ready() -> void:
	if critter:
		critter.petted.connect(_on_critter_petted)
		critter.fed.connect(_on_critter_fed)
		critter.mood_state_changed.connect(_on_mood_state_changed)
	
	if pet_button:
		pet_button.pressed.connect(func(): critter.pet())
	if bake_button:
		bake_button.pressed.connect(_on_open_bakery)
	if walk_button:
		walk_button.pressed.connect(_on_open_walk)

	if baking_ui:
		baking_ui.baked.connect(_on_baked_recipe)
		baking_ui.closed.connect(func(): baking_ui.visible = false)
		baking_ui.visible = false

	if gathering_walk:
		gathering_walk.item_collected.connect(_on_item_collected)
		gathering_walk.returned_to_haven.connect(func(): gathering_walk.visible = false)
		gathering_walk.visible = false

	update_hud()
	show_toast("Welcome to Cozy Critter Haven! Tap Capy to pet!")

func update_hud() -> void:
	if mood_bar and critter:
		mood_bar.value = critter.mood
	if hunger_bar and critter:
		hunger_bar.value = critter.hunger
	if state_label and critter:
		state_label.text = "Capy is %s" % critter.personality_state
	if coins_label:
		coins_label.text = "%d Coins" % coins

func show_toast(msg: String) -> void:
	if not toast_banner:
		return
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	toast_banner.text = msg
	toast_banner.visible = true
	toast_banner.modulate.a = 1.0
	if toast_backdrop:
		toast_backdrop.visible = true
		toast_backdrop.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(3.0)
	_toast_tween.tween_property(toast_banner, "modulate:a", 0.0, 0.5)
	if toast_backdrop:
		_toast_tween.parallel().tween_property(toast_backdrop, "modulate:a", 0.0, 0.5)
	_toast_tween.tween_callback(func():
		toast_banner.visible = false
		toast_banner.modulate.a = 1.0
		if toast_backdrop:
			toast_backdrop.visible = false
			toast_backdrop.modulate.a = 1.0
	)

func _on_critter_petted(_delta: float) -> void:
	update_hud()
	show_toast("Capy purrs happily! (+10 Mood)")

func _on_critter_fed(food: String, _delta: float) -> void:
	update_hud()
	show_toast("Fed %s to Capy! Delish!" % food)

func _on_mood_state_changed(_state: String) -> void:
	update_hud()

func _on_open_bakery() -> void:
	if gathering_walk:
		gathering_walk.visible = false
	if baking_ui:
		baking_ui.visible = true

func _on_open_walk() -> void:
	if baking_ui:
		baking_ui.visible = false
	if gathering_walk:
		gathering_walk.visible = true

func _on_baked_recipe(recipe: String, quality: String) -> void:
	coins += 20
	critter.feed(recipe)
	update_hud()
	show_toast("Baked %s (%s)! +20 Coins" % [recipe, quality])

func _on_item_collected(item: String, coins_earned: int) -> void:
	coins += coins_earned
	update_hud()
	show_toast("Collected %s! (+%d Coins)" % [item, coins_earned])
