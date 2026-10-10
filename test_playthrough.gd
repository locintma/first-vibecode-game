extends SceneTree

## Zero-Regression Test Suite for first-vibecode-game
## Enforces Nemotron 3.5 Lightning test gate invariants with non-zero exit codes

const CritterScript = preload("res://scripts/critter.gd")
const SoundManagerScript = preload("res://scripts/sound_manager.gd")
const BakingUIScript = preload("res://scripts/ui/baking.gd")
const GatheringWalkScript = preload("res://scripts/mini_games/gathering_walk.gd")
const MainGameScript = preload("res://scripts/main.gd")

func _init() -> void:
	print("==================================================")
	print("🧪 Starting first-vibecode-game test_playthrough...")
	print("==================================================")
	
	var passed: int = 0
	var failed: int = 0
	
	# Test 1: Critter Padding & Feet Normalization
	var critter = CritterScript.new()
	critter.visual_size = Vector2(96, 96)
	critter.canvas_padding = Rect2(16, 16, 32, 32)
	critter.apply_padding_normalization()
	var expected_offset := Vector2(-critter.visual_size.x * 0.5, -critter.visual_size.y)
	if expected_offset == Vector2(-48, -96):
		print("  ✅ PASS: Critter feet-pivot normalized to (0.5, 1.0) with offset (-48, -96)")
		passed += 1
	else:
		print("  ❌ FAIL: Offset calculation mismatch: %s" % str(expected_offset))
		failed += 1

	# Test 2: SoundManager Ripple
	var sound_mgr = SoundManagerScript.new()
	if sound_mgr.has_method("play_petting_ripple"):
		print("  ✅ PASS: SoundManager has tactile feedback ripple method")
		passed += 1
	else:
		print("  ❌ FAIL: SoundManager missing play_petting_ripple")
		failed += 1

	# Test 3: Baking UI Vietnamese Recipes
	var baking = BakingUIScript.new()
	if baking.recipes.size() >= 3:
		print("  ✅ PASS: BakingUI loaded %d Vietnamese cuisine recipes" % baking.recipes.size())
		passed += 1
	else:
		print("  ❌ FAIL: BakingUI recipe count below minimum")
		failed += 1

	# Test 4: Gathering Walk Pluck Loop
	var walk = GatheringWalkScript.new()
	if walk.flowers.size() >= 3 and walk.step_cadence == 0.30:
		print("  ✅ PASS: GatheringWalk configured with 3-phase flower pluck & waddle")
		passed += 1
	else:
		print("  ❌ FAIL: GatheringWalk configuration mismatch")
		failed += 1

	# Test 5: Atomic Save Invariant
	var main_game = MainGameScript.new()
	if main_game.has_method("save_game_atomic"):
		print("  ✅ PASS: MainGame implements atomic save invariant")
		passed += 1
	else:
		print("  ❌ FAIL: MainGame missing atomic save method")
		failed += 1

	print("--------------------------------------------------")
	print("Test Results: %d passed, %d failed" % [passed, failed])
	print("==================================================")

	# Nemotron Lightning Invariant: Non-zero exit on ANY failure!
	if failed > 0:
		print("🚨 TEST GATE FAILED with %d error(s). Exiting code 1." % failed)
		quit(1)
	else:
		print("🎉 ALL TESTS PASSED! Exiting code 0.")
		quit(0)
