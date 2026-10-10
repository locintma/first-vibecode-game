extends SceneTree

func _initialize() -> void:
	var scene = load("res://scenes/main.tscn")
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var c = main.get_node_or_null("Critter")
	print("CRITTER=", c)
	if c:
		print("  pos=", c.global_position, " scale=", c.scale, " visible=", c.visible, " script=", c.get_script())
	print("--- TREE ---")
	_dump(main, 0)
	quit(0)

func _dump(n: Node, d: int) -> void:
	var pos := "-"
	if n is Node2D:
		pos = str((n as Node2D).global_position)
	var sz := ""
	if n is Control:
		sz = " size=" + str((n as Control).size) + " off=" + str((n as Control).offset_top)
	print("  ".repeat(d), n.name, " [", n.get_class(), "] vis=", n.visible, " pos=", pos, sz)
	for ch in n.get_children():
		_dump(ch, d + 1)