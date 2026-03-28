extends PanelContainer

signal task_finished(task_id, success)
signal closed

@onready var title_label = $MarginContainer/VBoxContainer/TopRow/TitleLabel
@onready var feedback_label = $MarginContainer/VBoxContainer/FeedbackLabel
@onready var card_grid = $MarginContainer/VBoxContainer/CardGrid
@onready var continue_button = $MarginContainer/VBoxContainer/ContinueButton

var task_id := ""
var card_back_label := "?"
var open_buttons: Array = []
var matched_count := 0
var input_locked := false


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
	task_id = String(task_data.get("id", "memory_pairs"))
	card_back_label = String(task_data.get("card_back_label", "?"))
	title_label.text = String(task_data.get("prompt", "Find the two cards that match."))
	feedback_label.text = String(task_data.get("hint", "Click two cards and see if they match."))
	_build_cards(task_data.get("cards", []))


func _build_cards(base_cards: Array) -> void:
	for child in card_grid.get_children():
		child.queue_free()
	open_buttons.clear()
	matched_count = 0
	input_locked = false
	var deck: Array = []
	for card in base_cards:
		var label := String(card)
		deck.append(label)
		deck.append(label)
	deck.shuffle()
	card_grid.columns = min(4, max(2, int(ceil(deck.size() / 2.0))))
	for label in deck:
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 92)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 26)
		button.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08))
		button.text = card_back_label
		button.set_meta("card_label", label)
		button.pressed.connect(_on_card_pressed.bind(button))
		card_grid.add_child(button)


func _on_card_pressed(button: Button) -> void:
	if input_locked or button.disabled or open_buttons.has(button):
		return
	button.text = String(button.get_meta("card_label", ""))
	open_buttons.append(button)
	if open_buttons.size() < 2:
		return
	input_locked = true
	var first: Button = open_buttons[0]
	var second: Button = open_buttons[1]
	if String(first.get_meta("card_label", "")) == String(second.get_meta("card_label", "")):
		first.disabled = true
		second.disabled = true
		matched_count += 1
		feedback_label.text = "That is a happy match!"
		open_buttons.clear()
		input_locked = false
		if matched_count * 2 == card_grid.get_child_count():
			feedback_label.text = "You found every matching pair!"
			continue_button.visible = true
	else:
		feedback_label.text = "Those cards are different. Let's peek again."
		await get_tree().create_timer(0.7).timeout
		first.text = card_back_label
		second.text = card_back_label
		open_buttons.clear()
		input_locked = false


func _on_continue_button_pressed() -> void:
	emit_signal("task_finished", task_id, true)


func _on_close_button_pressed() -> void:
	emit_signal("closed")
