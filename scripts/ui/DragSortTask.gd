extends PanelContainer

signal task_finished(task_id, success)
signal closed

const DRAGGABLE_SCRIPT := preload("res://scripts/ui/DraggablePiece.gd")
const DEFAULT_TOKEN_TEXTURE := preload("res://assets/art/first_slice/props/waterfall/prop_task_sparkle_piece.svg")

@onready var title_label = $MarginContainer/VBoxContainer/TopRow/TitleLabel
@onready var feedback_label = $MarginContainer/VBoxContainer/FeedbackLabel
@onready var target_row = $MarginContainer/VBoxContainer/PlayArea/TargetRow
@onready var piece_area = $MarginContainer/VBoxContainer/PlayArea/PieceArea
@onready var continue_button = $MarginContainer/VBoxContainer/ContinueButton

var task_id := ""
var targets: Dictionary = {}
var target_slots: Dictionary = {}
var placed_piece_ids: Array = []


func _ready() -> void:
	_apply_style()
	continue_button.visible = false


func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 1.0, 0.98)
	style.corner_radius_top_left = 28
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_left = 28
	style.corner_radius_bottom_right = 28
	style.border_color = Color(0.18, 0.18, 0.18, 0.95)
	style.set_border_width_all(3)
	style.shadow_size = 10
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.12)
	add_theme_stylebox_override("panel", style)


func setup(task_data: Dictionary) -> void:
	task_id = String(task_data.get("id", "drag_sort"))
	title_label.text = String(task_data.get("prompt", "Drag each helper into the right cozy basket."))
	feedback_label.text = String(task_data.get("hint", "Pick up a helper and drop it inside the right basket."))
	_build_targets(task_data.get("categories", []))
	_build_pieces(task_data.get("pieces", []))


func _build_targets(categories: Array) -> void:
	for child in target_row.get_children():
		child.queue_free()
	targets.clear()
	target_slots.clear()
	for category in categories:
		var category_dict: Dictionary = category
		var category_id := String(category_dict.get("id", "basket_%d" % targets.size()))
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(180, 150)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.96, 0.98, 1.0)
		style.corner_radius_top_left = 28
		style.corner_radius_top_right = 28
		style.corner_radius_bottom_left = 28
		style.corner_radius_bottom_right = 28
		style.border_color = Color(0.37, 0.57, 0.81)
		style.set_border_width_all(3)
		panel.add_theme_stylebox_override("panel", style)
		var label := Label.new()
		label.text = String(category_dict.get("label", "Basket"))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.anchor_right = 1.0
		label.anchor_bottom = 1.0
		label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08))
		label.add_theme_font_size_override("font_size", 24)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel.add_child(label)
		target_row.add_child(panel)
		targets[category_id] = panel
		target_slots[category_id] = 0


func _build_pieces(pieces: Array) -> void:
	for child in piece_area.get_children():
		child.queue_free()
	placed_piece_ids.clear()
	var x_pos := 30.0
	var y_pos := 24.0
	for piece_data in pieces:
		var piece_dict: Dictionary = piece_data
		var piece := TextureRect.new()
		piece.set_script(DRAGGABLE_SCRIPT)
		piece.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		piece.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		piece.custom_minimum_size = Vector2(112, 112)
		piece.position = Vector2(x_pos, y_pos)
		piece.size = Vector2(112, 112)
		piece.texture = DEFAULT_TOKEN_TEXTURE
		piece.modulate = _parse_color(piece_dict.get("color", [1.0, 0.88, 0.52, 1.0]), Color(1.0, 0.88, 0.52))
		piece.set_meta("piece_id", String(piece_dict.get("id", "piece_%d" % piece_area.get_child_count())))
		piece.set_meta("category", String(piece_dict.get("category", "")))
		piece.piece_released.connect(_on_piece_released)
		var label := Label.new()
		label.text = String(piece_dict.get("label", "Helper"))
		label.anchor_right = 1.0
		label.anchor_bottom = 1.0
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08))
		label.add_theme_font_size_override("font_size", 18)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		piece.add_child(label)
		piece_area.add_child(piece)
		x_pos += 130.0
		if x_pos > 470.0:
			x_pos = 30.0
			y_pos += 126.0


func _on_piece_released(piece: TextureRect) -> void:
	var piece_id := String(piece.get_meta("piece_id", ""))
	if placed_piece_ids.has(piece_id):
		return
	for category_id in targets.keys():
		var target: PanelContainer = targets[category_id]
		var target_rect := Rect2(target.global_position, target.size)
		var piece_rect := Rect2(piece.global_position, piece.size)
		if not target_rect.intersects(piece_rect):
			continue
		if category_id == String(piece.get_meta("category", "")):
			var slot := int(target_slots.get(category_id, 0))
			var local_x := 16.0 + float(slot % 2) * 72.0
			var local_y := 50.0 + float(slot / 2) * 68.0
			piece.global_position = target.global_position + Vector2(local_x, local_y)
			piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
			placed_piece_ids.append(piece_id)
			target_slots[category_id] = slot + 1
			feedback_label.text = "That helper found the right basket."
			if placed_piece_ids.size() == piece_area.get_child_count():
				feedback_label.text = "You sorted every helper beautifully!"
				continue_button.visible = true
			return
		piece.reset_to_home()
		feedback_label.text = "That basket is for something else. Try another one."
		return
	piece.reset_to_home()
	feedback_label.text = "Drop the helper right inside a basket."


func _parse_color(value, fallback: Color) -> Color:
	if value is Array and value.size() >= 3:
		return Color(float(value[0]), float(value[1]), float(value[2]), float(value[3]) if value.size() > 3 else 1.0)
	return fallback


func _on_continue_button_pressed() -> void:
	emit_signal("task_finished", task_id, true)


func _on_close_button_pressed() -> void:
	emit_signal("closed")
