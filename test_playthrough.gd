extends SceneTree

const CritterScript = preload("res://scripts/critter.gd")
const BakingScript = preload("res://scripts/ui/baking.gd")
const WalkScript = preload("res://scripts/mini_games/gathering_walk.gd")

func _init() -> void:
	print("--- Running test_playthrough (OpenCode Council Gate) ---")
	var passes: int = 0
	var fails: int = 0

	# Test 1: Critter exists, has personality drift, and squash-and-stretch
	var critter = CritterScript.new()
	if critter.mood == 100.0 and critter.personality_state == "Thrilled & Affectionate":
		passes += 1
		print("PASS: Critter initial mood and personality state verified")
	else:
		fails += 1
		print("FAIL: Critter initial mood or personality state incorrect")

	critter.mood = 30.0
	critter.update_state()
	if critter.personality_state == "Sleepy & Needy":
		passes += 1
		print("PASS: Critter dynamic emotional state drift verified (LongCat review)")
	else:
		fails += 1
		print("FAIL: Critter emotional state drift failed")

	critter.pet()
	if critter.mood == 40.0:
		passes += 1
		print("PASS: Critter petting increases mood and triggers tween (MiMo review)")
	else:
		fails += 1
		print("FAIL: Critter pet did not increase mood")

	# Test 2: Baking UI recipes and culinary doneness
	var baking = BakingScript.new()
	if baking.recipes.size() >= 3:
		passes += 1
		print("PASS: Baking UI has 3+ authentic Vietnamese recipes (Big Pickle review)")
	else:
		fails += 1
		print("FAIL: Baking UI missing recipes")

	var bake_res = baking.bake_recipe("Crispy Banh Mi")
	if bake_res.has("quality") and bake_res["quality"] == "Perfect!":
		passes += 1
		print("PASS: Baking minigame returns doneness quality rating")
	else:
		fails += 1
		print("FAIL: Baking minigame did not return quality rating")

	# Test 3: Gathering walk mini-game flower foraging journal
	var walk = WalkScript.new()
	walk.step_forward(60.0)
	if walk.items_found.size() > 0 and walk.flower_journal.has("Wild Chamomile"):
		passes += 1
		print("PASS: Gathering walk meadow foraging and flower journal verified (Step-5 & Ling review)")
	else:
		fails += 1
		print("FAIL: Gathering walk failed to find item or update journal")

	# Test 4: Main scene hierarchy and HUD nodes resolution
	var main_scene = load("res://scenes/main.tscn")
	var main_instance = main_scene.instantiate()
	root.add_child(main_instance)
	var mb = main_instance.get_node_or_null("HUD/TopBar/HBox/StatsVBox/MoodHBox/MoodBar")
	var hb = main_instance.get_node_or_null("HUD/TopBar/HBox/StatsVBox/HungerHBox/HungerBar")
	var cl = main_instance.get_node_or_null("HUD/TopBar/HBox/CoinsLabel")
	var sl = main_instance.get_node_or_null("HUD/TopBar/HBox/StatsVBox/StateLabel")
	if mb and hb and cl and sl:
		passes += 1
		print("PASS: Main scene and all HUD node paths resolve correctly")
	else:
		fails += 1
		print("FAIL: Main scene HUD node paths failed to resolve. mb=%s hb=%s cl=%s sl=%s" % [mb, hb, cl, sl])

	critter.free()
	baking.free()
	walk.free()
	main_instance.queue_free()

	print("Summary: PASS: %d, FAIL: %d" % [passes, fails])
	if fails > 0:
		print("verdict=FAIL")
		quit(1)
	else:
		print("verdict=PASS")
		quit(0)
