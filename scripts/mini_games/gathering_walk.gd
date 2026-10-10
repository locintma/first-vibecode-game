extends Node2D
class_name GatheringWalk

signal item_collected(item_name: String)

var walk_distance: float = 0.0
var items_found: Array[String] = []

func _ready() -> void:
	pass

func step_forward(amount: float = 10.0) -> void:
	walk_distance += amount
	if walk_distance >= 50.0 and items_found.is_empty():
		collect_item("Wild Chamomile")

func collect_item(item_name: String) -> void:
	items_found.append(item_name)
	item_collected.emit(item_name)
