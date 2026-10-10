extends SceneTree

const CritterScript = preload("res://scripts/critter.gd")
const BakingScript = preload("res://scripts/ui/baking.gd")
const WalkScript = preload("res://scripts/mini_games/gathering_walk.gd")

func _init() -> void:
	print("--- Running test_playthrough ---")
	var passes: int = 0
	var fails: int = 0

	# Test 1: Critter exists and can be petted
	var critter = CritterScript.new()
	if critter.mood == 100.0:
		passes += 1
		print("PASS: Critter initial mood 100.0")
	else:
		fails += 1
		print("FAIL: Critter initial mood incorrect")

	critter.mood = 50.0
	critter.pet()
	if critter.mood == 60.0:
		passes += 1
		print("PASS: Critter petting increases mood")
	else:
		fails += 1
		print("FAIL: Critter pet did not increase mood")

	# Test 2: Baking UI recipes exist
	var baking = BakingScript.new()
	if baking.recipes.size() >= 3:
		passes += 1
		print("PASS: Baking UI has 3+ recipes")
	else:
		fails += 1
		print("FAIL: Baking UI missing recipes")

	# Test 3: Gathering walk mini-game
	var walk = WalkScript.new()
	walk.step_forward(60.0)
	if walk.items_found.size() > 0:
		passes += 1
		print("PASS: Gathering walk finds items")
	else:
		fails += 1
		print("FAIL: Gathering walk failed to find item")

	critter.free()
	baking.free()
	walk.free()

	print("Summary: PASS: %d, FAIL: %d" % [passes, fails])
	if fails > 0:
		print("verdict=FAIL")
		quit(1)
	else:
		print("verdict=PASS")
		quit(0)
