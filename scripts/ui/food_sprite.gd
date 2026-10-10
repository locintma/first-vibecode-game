extends Control
class_name FoodSprite

## Procedurally illustrated Vietnamese dishes. Drawn in a normalized 100x100
## box then scaled to `size`, so the same sprite works at 40px or 160px.

enum Dish { PHO_BO, BANH_MI, CA_PHE_TRUNG }

@export var dish: int = Dish.PHO_BO:
	set(value):
		dish = value
		_steam_t = 0.0
		queue_redraw()

@export var animated: bool = true:
	set(value):
		animated = value
		set_process(value)

var _steam_t: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(animated)

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	# Steam is the only animated element; it wraps over a two second cycle.
	_steam_t = fmod(_steam_t + delta * 0.55, 1.0)
	queue_redraw()

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var s: float = min(size.x, size.y) / 100.0
	var origin: Vector2 = (size - Vector2(100, 100) * s) * 0.5
	draw_set_transform(origin, 0.0, Vector2(s, s))
	match dish:
		Dish.PHO_BO:
			_draw_pho_bo()
		Dish.BANH_MI:
			_draw_banh_mi()
		Dish.CA_PHE_TRUNG:
			_draw_ca_phe_trung()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# --- Pho Bo: broth bowl, noodles, herbs, rising steam curls ---
func _draw_pho_bo() -> void:
	var bowl = Color(0.93, 0.95, 0.97)
	var bowl_shade = Color(0.76, 0.82, 0.88)
	var broth = Color(0.42, 0.26, 0.15)
	var broth_hi = Color(0.56, 0.36, 0.21)

	# Steam curls behind the rim, drifting up and fading out
	for i in range(3):
		var p: float = fmod(_steam_t + i * 0.33, 1.0)
		var x: float = 34.0 + i * 16.0 + sin(p * TAU + i) * 3.0
		var y: float = 44.0 - p * 40.0
		var a: float = 0.42 * (1.0 - p) * (1.0 - p)
		var w: float = 3.4 - p * 1.4
		draw_line(Vector2(x - w, y), Vector2(x + w, y + 1.0), Color(1, 1, 1, a), 2.6, true)
		draw_line(Vector2(x - w, y - 3.0), Vector2(x + w, y - 2.0), Color(1, 1, 1, a * 0.7), 2.0, true)

	# Bowl body and foot
	_ellipse(Vector2(50, 92), 26, 6, Color(0.2, 0.15, 0.1, 0.18))
	draw_colored_polygon(PackedVector2Array([
		Vector2(18, 56), Vector2(82, 56), Vector2(74, 86), Vector2(26, 86)
	]), bowl)
	draw_colored_polygon(PackedVector2Array([
		Vector2(66, 56), Vector2(82, 56), Vector2(74, 86), Vector2(60, 86)
	]), bowl_shade)

	# Broth surface
	_ellipse(Vector2(50, 56), 32, 11, broth)
	_ellipse(Vector2(44, 54), 22, 6, broth_hi)

	# Rice noodles peeking through the broth
	for i in range(3):
		var nx: float = 34.0 + i * 14.0
		draw_arc(Vector2(nx, 55.0), 7.0, PI * 1.05, PI * 1.95, 10, Color(0.95, 0.89, 0.72, 0.85), 2.0, true)

	# Herbs and beef
	_ellipse(Vector2(44, 52), 6, 3, Color(0.36, 0.56, 0.28))
	_ellipse(Vector2(57, 51), 5, 3, Color(0.42, 0.62, 0.30))
	draw_circle(Vector2(62, 55), 4.5, Color(0.62, 0.30, 0.26))
	draw_circle(Vector2(38, 56), 4.0, Color(0.66, 0.33, 0.28))

	# Rim highlight
	_ellipse_outline(Vector2(50, 56), 32, 11, bowl, 2.4)

# --- Banh Mi: scored golden crust with pickle and herb filling ---
func _draw_banh_mi() -> void:
	var crust = Color(0.85, 0.64, 0.25)
	var crust_lo = Color(0.70, 0.49, 0.17)
	var crust_hi = Color(0.95, 0.79, 0.44)
	var daikon = Color(0.93, 0.90, 0.78)
	var cuke = Color(0.60, 0.78, 0.44)
	var herb = Color(0.36, 0.60, 0.32)

	_ellipse(Vector2(50, 84), 36, 6, Color(0.2, 0.15, 0.1, 0.18))

	# Baguette silhouette, tilted slightly
	var pts := PackedVector2Array([
		Vector2(12, 62), Vector2(24, 44), Vector2(76, 44), Vector2(88, 62),
		Vector2(80, 76), Vector2(20, 76)
	])
	draw_colored_polygon(pts, crust)
	# Lower half in shadow gives the loaf volume
	draw_colored_polygon(PackedVector2Array([
		Vector2(20, 76), Vector2(80, 76), Vector2(86, 64), Vector2(16, 64)
	]), crust_lo)

	# Filling spilling from the split
	_ellipse(Vector2(36, 46), 9, 5, daikon)
	_ellipse(Vector2(52, 45), 8, 4, cuke)
	_ellipse(Vector2(66, 47), 7, 4, herb)
	draw_circle(Vector2(28, 44), 4.0, herb)
	draw_circle(Vector2(44, 43), 3.4, Color(0.86, 0.36, 0.32))
	draw_circle(Vector2(60, 44), 3.4, Color(0.86, 0.36, 0.32))

	# Diagonal crust scoring
	for i in range(4):
		var sx: float = 26.0 + i * 14.0
		draw_line(Vector2(sx, 56), Vector2(sx + 9, 70), crust_hi, 3.0, true)
		draw_line(Vector2(sx, 57.5), Vector2(sx + 9, 71.5), Color(0.62, 0.43, 0.14, 0.5), 1.2, true)

	# Top highlight along the crown
	draw_line(Vector2(26, 47.5), Vector2(74, 47.5), Color(1, 0.95, 0.78, 0.55), 2.0, true)

# --- Ca Phe Trung: dark coffee under a whipped egg-crema swirl ---
func _draw_ca_phe_trung() -> void:
	var glass = Color(0.88, 0.94, 0.96)
	var coffee = Color(0.29, 0.17, 0.09)
	var crema = Color(0.91, 0.79, 0.56)
	var crema_hi = Color(0.98, 0.90, 0.72)

	_ellipse(Vector2(50, 92), 24, 6, Color(0.2, 0.15, 0.1, 0.18))

	# Handle
	draw_arc(Vector2(78, 56), 13.0, -PI * 0.55, PI * 0.55, 14, glass, 6.0, true)
	draw_arc(Vector2(78, 56), 13.0, -PI * 0.55, PI * 0.55, 14, Color(0.78, 0.87, 0.91), 2.0, true)

	# Cup body, slightly tapered
	draw_colored_polygon(PackedVector2Array([
		Vector2(24, 42), Vector2(76, 42), Vector2(70, 88), Vector2(30, 88)
	]), glass)
	# Coffee fill
	draw_colored_polygon(PackedVector2Array([
		Vector2(26, 50), Vector2(74, 50), Vector2(70, 84), Vector2(30, 84)
	]), coffee)
	draw_colored_polygon(PackedVector2Array([
		Vector2(60, 50), Vector2(74, 50), Vector2(70, 84), Vector2(58, 84)
	]), Color(0.22, 0.12, 0.06))

	# Egg crema cap
	_ellipse(Vector2(50, 50), 24, 9, crema)
	_ellipse(Vector2(43, 48), 15, 5, crema_hi)

	# Creama swirl
	var swirl := PackedVector2Array([
		Vector2(38, 49), Vector2(45, 43), Vector2(54, 48), Vector2(62, 42)
	])
	draw_polyline(swirl, Color(0.78, 0.63, 0.40, 0.85), 3.0, true)
	draw_circle(Vector2(62, 42), 3.2, crema_hi)

	# Glass sheen and rim
	draw_line(Vector2(34, 58), Vector2(36, 78), Color(1, 1, 1, 0.5), 3.0, true)
	_ellipse_outline(Vector2(50, 50), 24, 9, Color(0.80, 0.88, 0.93), 2.0)

func _ellipse(center: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(28):
		var th: float = i * (TAU / 28.0)
		pts.append(center + Vector2(cos(th) * rx, sin(th) * ry))
	draw_colored_polygon(pts, col)

func _ellipse_outline(center: Vector2, rx: float, ry: float, col: Color, w: float) -> void:
	var pts := PackedVector2Array()
	for i in range(29):
		var th: float = i * (TAU / 28.0)
		pts.append(center + Vector2(cos(th) * rx, sin(th) * ry))
	draw_polyline(pts, col, w, true)