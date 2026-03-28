extends PanelContainer

signal task_finished(task_id, success)
signal closed

@onready var title_label = $MarginContainer/VBoxContainer/TopRow/TitleLabel
@onready var feedback_label = $MarginContainer/VBoxContainer/FeedbackLabel
@onready var option_grid = $MarginContainer/VBoxContainer/OptionGrid
@onready var continue_button = $MarginContainer/VBoxContainer/ContinueButton

var task_id := ""
var correct_option := ""
var success_text := "Wonderful helping!"
var retry_text := "Let's try another one together."


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
	task_id = String(task_data.get("id", "choice_task"))
	correct_option = String(task_data.get("correct_option", ""))
	success_text = String(task_data.get("success_text", success_text))
	retry_text = String(task_data.get("retry_text", retry_text))
	title_label.text = String(task_data.get("prompt", "Choose the one that matches best."))
	feedback_label.text = String(task_data.get("hint", "Click one big choice."))
	_build_options(task_data.get("options", []))


func _build_options(options: Array) -> void:
	for child in option_grid.get_children():
		child.queue_free()
	option_grid.columns = 2 if options.size() > 3 else 1
	for option in options:
		var option_dict: Dictionary = option
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 90)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 28)
		button.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08))
		button.text = String(option_dict.get("label", "Choice"))
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(_on_option_pressed.bind(String(option_dict.get("id", button.text.to_lower()))))
		option_grid.add_child(button)


func _on_option_pressed(option_id: String) -> void:
	if option_id == correct_option:
		feedback_label.text = success_text
		continue_button.visible = true
		for button in option_grid.get_children():
			button.disabled = true
	else:
		feedback_label.text = retry_text


func _on_continue_button_pressed() -> void:
	emit_signal("task_finished", task_id, true)


func _on_close_button_pressed() -> void:
	emit_signal("closed")
