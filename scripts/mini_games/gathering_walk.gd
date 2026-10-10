extends Control
class_name GatheringWalk

signal item_collected(item_name: String, coins_awarded: int)
signal flower_bloomed(flower_name: String, position: Vector2)
signal returned_to_haven

var walk_distance: float = 0.0
var items_found: Array[String] = []
var flower_journal: Array[String] = []

@onready var walk_btn: Button = $UI/WalkButton
@onready var back_btn: Button = $UI/BackButton
@onready var status_lbl: Label = $UI/StatusLabel
@onready var journal_lbl: Label = $UI/JournalLabel

func _ready() -> void:
	if walk_btn:
		walk_btn.pressed.connect(_on_walk_pressed)
	if back_btn:
		back_btn.pressed.connect(_on_back_pressed)
	update_labels()

func _on_walk_pressed() -> void:
	step_forward(20.0)

func step_forward(amount: float = 10.0) -> void:
	walk_distance += amount
	if walk_distance >= 40.0 and not flower_journal.has("Wild Chamomile"):
		collect_item("Wild Chamomile", 15)
	elif walk_distance >= 80.0 and not flower_journal.has("Lotus Blossom"):
		collect_item("Lotus Blossom", 25)
	elif walk_distance >= 120.0 and not flower_journal.has("Meadow Clover"):
		collect_item("Meadow Clover", 35)
	else:
		if status_lbl:
			status_lbl.text = "Strolling along the sunlit watercolor path... (%.0f m)" % walk_distance
	update_labels()

func collect_item(item_name: String, coin_reward: int = 10) -> void:
	items_found.append(item_name)
	if not flower_journal.has(item_name):
		flower_journal.append(item_name)
		flower_bloomed.emit(item_name, Vector2(240, 320))
	item_collected.emit(item_name, coin_reward)
	if status_lbl:
		status_lbl.text = "Found %s! (+%d Coins)" % [item_name, coin_reward]

func update_labels() -> void:
	if journal_lbl:
		journal_lbl.text = "Flower Journal: " + (", ".join(flower_journal) if not flower_journal.is_empty() else "Empty (Take a stroll!)")

func _on_back_pressed() -> void:
	returned_to_haven.emit()
	visible = false
