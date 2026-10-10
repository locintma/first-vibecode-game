extends SceneTree

func _initialize() -> void:
	var img := Image.load_from_file("/tmp/haven_before.png")
	print("SIZE=", img.get_size(), " fmt=", img.get_format())
	var pts := {
		"bg_corner": Vector2i(5, 5),
		"wall": Vector2i(240, 300),
		"floor": Vector2i(240, 620),
		"rugouter": Vector2i(120, 400),
		"ruginner": Vector2i(200, 500),
		"critter_head": Vector2i(240, 428),
		"critter_eyeL": Vector2i(220, 422),
		"basket": Vector2i(60, 440),
		"monstera": Vector2i(410, 400),
		"garland": Vector2i(240, 145),
		"sunbeam": Vector2i(240, 180),
		"toast": Vector2i(60, 125),
	}
	for k in pts.keys():
		var p: Vector2i = pts[k]
		if p.x < img.get_width() and p.y < img.get_height():
			print(k, " ", p, " -> ", img.get_pixelv(p))
		else:
			print(k, " ", p, " -> OUT OF BOUNDS")
	print("--- display settings ---")
	print("win size=", DisplayServer.window_get_size(), " viewport=", root.get_visible_rect().size)
	quit(0)