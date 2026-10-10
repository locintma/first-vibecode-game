extends Node2D
class_name GatheringWalk

## Scenic nature gathering walk meadow path
## Implements Step-5 Preview's watercolor meadow and pluck loop

signal item_foraged(item_type: String)

@export var walk_speed: float = 120.0
@export var step_cadence: float = 0.30 # seconds per waddle step
var step_timer: float = 0.0

# 3-Plane environmental layers
@onready var background_layer: Node2D = $BackgroundParallax
@onready var midground_flowers: Node2D = $Wildflowers
@onready var foreground_grass: Node2D = $ForegroundGrass
@onready var critter: Node2D = $CritterNode

# Harvestable flora
var flowers: Array[Dictionary] = [
	{"name": "Lavender Bloom", "harvested": false, "regrowth_timer": 0.0},
	{"name": "Meadow Sunflower", "harvested": false, "regrowth_timer": 0.0},
	{"name": "Mint Leaf", "harvested": false, "regrowth_timer": 0.0}
]

func _process(delta: float) -> void:
	process_critter_waddle(delta)
	process_regrowth(delta)

## Step-5 Waddle cycle: 0.28-0.32s per step with 2-3px body bob and 2-3 deg roll
func process_critter_waddle(delta: float) -> void:
	if not critter:
		return
	step_timer += delta
	var step_progress: float = fmod(step_timer, step_cadence) / step_cadence
	var bob_y: float = sin(step_progress * TAU * 2.0) * 2.5
	var roll_deg: float = sin(step_progress * TAU) * 2.5
	critter.position.y = bob_y
	critter.rotation_degrees = roll_deg

## Crisp 3-phase flower pluck: 70ms stretch (1.08x) -> 90ms snap (0.92x) -> 180ms spring settle
func pluck_flower(flower_node: Node2D, flower_index: int) -> void:
	var f: Dictionary = flowers[flower_index]
	if f["harvested"]:
		return
	f["harvested"] = true
	f["regrowth_timer"] = 15.0 # 15s gentle regrowth period
	
	emit_signal("item_foraged", f["name"])
	
	var tween: Tween = create_tween()
	# Phase 1: 70ms anticipatory stretch
	tween.tween_property(flower_node, "scale", Vector2(1.08, 1.08), 0.07)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Phase 2: 90ms pluck snap
	tween.tween_property(flower_node, "scale", Vector2(0.92, 0.92), 0.09)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	# Phase 3: 180ms springy settle
	tween.tween_property(flower_node, "scale", Vector2(1.0, 1.0), 0.18)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func process_regrowth(delta: float) -> void:
	for f in flowers:
		if f["harvested"]:
			f["regrowth_timer"] -= delta
			if f["regrowth_timer"] <= 0.0:
				f["harvested"] = false
