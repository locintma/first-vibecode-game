extends Node2D
class_name GatheringWalk

signal item_collected(item_name: String, coins_awarded: int)
signal flower_bloomed(flower_name: String, position: Vector2)

var walk_distance: float = 0.0
var items_found: Array[String] = []
var flower_journal: Array[String] = []

func _ready() -> void:
	pass

func step_forward(amount: float = 10.0) -> void:
	walk_distance += amount
	# Step-5 Foraging Loop: Generous forgiving radius, journal rewards, and meadow transformation
	if walk_distance >= 50.0 and items_found.is_empty():
		collect_item("Wild Chamomile", 15)

func collect_item(item_name: String, coin_reward: int = 10) -> void:
	items_found.append(item_name)
	if not flower_journal.has(item_name):
		flower_journal.append(item_name)
		flower_bloomed.emit(item_name, Vector2(270, 450))
	item_collected.emit(item_name, coin_reward)
