extends PanelContainer

signal task_finished(task_id, success)
signal closed

@onready var title_label = $MarginContainer/VBoxContainer/TopRow/TitleLabel
@onready var feedback_label = $MarginContainer/VBoxContainer/FeedbackLabel
@onready var progress_label = $MarginContainer/VBoxContainer/ProgressLabel
@onready var stone_row = $MarginContainer/VBoxContainer/StoneRow
@onready var continue_button = $MarginContainer/VBoxContainer/ContinueButton

var task_id := "splash_sequence"
var expected_sequence := [1, 2, 3, 4]
var progress_index := 0


func _ready() -> void:
	_apply_style()
	continue_button.visible = false
	for button in stone_row.get_children():
		button.pressed.connect(_on_stone_pressed.bind(int(button.text)))
	_update_progress()


func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.94, 0.99, 0.96, 0.98)
	style.corner_radius_top_left = 26
	style.corner_radius_top_right = 26
	style.corner_radius_bottom_left = 26
	style.corner_radius_bottom_right = 26
	style.border_color = Color(0.37, 0.66, 0.46)
	style.set_border_width_all(4)
	add_theme_stylebox_override("panel", style)


func setup(task_data: Dictionary) -> void:
	task_id = String(task_data.get("id", task_id))
	title_label.text = String(task_data.get("prompt", "Tap the splash stones in order: 1, 2, 3, 4."))


func _on_stone_pressed(value: int) -> void:
	if value == expected_sequence[progress_index]:
		progress_index += 1
		feedback_label.text = "Splash!"
		_update_progress()
		if progress_index >= expected_sequence.size():
			feedback_label.text = "You played the splash song in order!"
			continue_button.visible = true
			for button in stone_row.get_children():
				button.disabled = true
	else:
		progress_index = 0
		feedback_label.text = "Let's start again with stone 1."
		_update_progress()


func _update_progress() -> void:
	progress_label.text = "Stones tapped: %d / %d" % [progress_index, expected_sequence.size()]


func _on_continue_button_pressed() -> void:
	emit_signal("task_finished", task_id, true)


func _on_close_button_pressed() -> void:
	emit_signal("closed")

