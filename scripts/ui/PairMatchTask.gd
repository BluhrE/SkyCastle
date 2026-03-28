extends PanelContainer

signal task_finished(task_id, success)
signal closed

@onready var title_label = $MarginContainer/VBoxContainer/TopRow/TitleLabel
@onready var feedback_label = $MarginContainer/VBoxContainer/FeedbackLabel
@onready var left_column = $MarginContainer/VBoxContainer/PairRow/LeftColumn
@onready var right_column = $MarginContainer/VBoxContainer/PairRow/RightColumn
@onready var continue_button = $MarginContainer/VBoxContainer/ContinueButton

var task_id := ""
var selected_left := ""
var left_buttons: Dictionary = {}
var right_buttons: Dictionary = {}
var matched_ids: Array = []


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
	task_id = String(task_data.get("id", "pair_match"))
	title_label.text = String(task_data.get("prompt", "Match the friends that belong together."))
	feedback_label.text = String(task_data.get("hint", "Pick one from the left, then one from the right."))
	_build_pairs(task_data.get("pairs", []))


func _build_pairs(pairs: Array) -> void:
	for child in left_column.get_children():
		child.queue_free()
	for child in right_column.get_children():
		child.queue_free()
	left_buttons.clear()
	right_buttons.clear()
	matched_ids.clear()
	selected_left = ""
	for pair in pairs:
		var pair_dict: Dictionary = pair
		var pair_id := String(pair_dict.get("id", "pair_%d" % left_buttons.size()))
		var left_button := _make_pair_button(String(pair_dict.get("left", "Left")))
		var right_button := _make_pair_button(String(pair_dict.get("right", "Right")))
		left_button.pressed.connect(_on_left_pressed.bind(pair_id))
		right_button.pressed.connect(_on_right_pressed.bind(pair_id))
		left_column.add_child(left_button)
		right_column.add_child(right_button)
		left_buttons[pair_id] = left_button
		right_buttons[pair_id] = right_button


func _make_pair_button(text_value: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 84)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 26)
	button.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08))
	button.text = text_value
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return button


func _on_left_pressed(pair_id: String) -> void:
	if matched_ids.has(pair_id):
		return
	selected_left = pair_id
	feedback_label.text = "Now click the match on the right."
	for id in left_buttons.keys():
		var button: Button = left_buttons[id]
		button.modulate = Color(1.0, 0.94, 0.84) if id == pair_id else Color.WHITE


func _on_right_pressed(pair_id: String) -> void:
	if matched_ids.has(pair_id):
		return
	if selected_left.is_empty():
		feedback_label.text = "Pick one on the left first."
		return
	if selected_left == pair_id:
		var left_button: Button = left_buttons[pair_id]
		var right_button: Button = right_buttons[pair_id]
		left_button.disabled = true
		right_button.disabled = true
		left_button.modulate = Color(0.84, 1.0, 0.86)
		right_button.modulate = Color(0.84, 1.0, 0.86)
		matched_ids.append(pair_id)
		selected_left = ""
		feedback_label.text = "That pair fits just right."
		if matched_ids.size() == left_buttons.size():
			feedback_label.text = "You matched every helper pair!"
			continue_button.visible = true
	else:
		feedback_label.text = "Those two are different. Let's try again."
		selected_left = ""
		for button in left_buttons.values():
			button.modulate = Color.WHITE


func _on_continue_button_pressed() -> void:
	emit_signal("task_finished", task_id, true)


func _on_close_button_pressed() -> void:
	emit_signal("closed")
