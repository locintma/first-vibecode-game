extends SceneTree

var _frames := 0

func _initialize() -> void:
	var scene = load("res://scenes/main.tscn")
	var main = scene.instantiate()
	root.add_child(main)
	for i in range(45):
		await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(OS.get_environment("SHOT_PATH"))
	quit(0)