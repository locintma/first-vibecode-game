extends PanelContainer
class_name BadgePill

## Mint-green checkmark pill. Replaces raw ratio text like "OK 5/1" with a
## rounded badge that reads as a state at a glance. The checkmark is drawn
## rather than typed, since the project ships no emoji/symbol font.

const MINT_READY := Color(0.20, 0.62, 0.42)
const MINT_EDGE := Color(0.13, 0.46, 0.31)
const MUTED := Color(0.45, 0.47, 0.52)
const MUTED_EDGE := Color(0.33, 0.35, 0.40)

var is_ready: bool = false:
	set(value):
		is_ready = value
		_apply_style()
		if _mark:
			_mark.done = value
			_mark.queue_redraw()

@onready var _mark: CheckMark
@onready var _label: Label

func _init() -> void:
	add_theme_stylebox_override("panel", _style(MINT_READY, MINT_EDGE))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	add_child(row)
	_mark = CheckMark.new()
	_mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_mark.custom_minimum_size = Vector2(11, 11)
	row.add_child(_mark)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 10)
	_label.add_theme_color_override("font_color", Color(0.97, 1.0, 0.98))
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_label)

func setup(text: String, ready: bool) -> void:
	if _label:
		_label.text = text
	is_ready = ready
	if _mark:
		_mark.queue_redraw()

func _style(fill: Color, edge: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = edge
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(9)
	sb.content_margin_left = 6.0
	sb.content_margin_right = 6.0
	sb.content_margin_top = 3.0
	sb.content_margin_bottom = 3.0
	return sb

func _apply_style() -> void:
	if is_ready:
		add_theme_stylebox_override("panel", _style(MINT_READY, MINT_EDGE))
	else:
		add_theme_stylebox_override("panel", _style(MUTED, MUTED_EDGE))

## Checkmark when satisfied, hollow ring when still short.
class CheckMark extends Control:
	var done: bool = true

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var ink := Color(0.97, 1.0, 0.98)
		if done:
			draw_polyline(PackedVector2Array([
				Vector2(1.5, 6.5), Vector2(4.5, 9.5), Vector2(10.5, 2.5)
			]), ink, 2.4, true)
		else:
			draw_arc(Vector2(6, 6), 3.6, 0.0, TAU, 16, ink, 1.8, true)