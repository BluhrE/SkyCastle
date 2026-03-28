extends PanelContainer

signal task_finished(task_id, success)
signal closed

@onready var title_label = $MarginContainer/VBoxContainer/TopRow/TitleLabel
@onready var feedback_label = $MarginContainer/VBoxContainer/FeedbackLabel
@onready var answer_row = $MarginContainer/VBoxContainer/AnswerRow
@onready var continue_button = $MarginContainer/VBoxContainer/ContinueButton

var task_id := "count_drops"
var correct_answer := 5


func _ready() -> void:
	_apply_style()
	continue_button.visible = false
	for button in answer_row.get_children():
		button.pressed.connect(_on_answer_pressed.bind(int(button.text)))


func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.94, 0.98, 1.0, 0.98)
	style.corner_radius_top_left = 26
	style.corner_radius_top_right = 26
	style.corner_radius_bottom_left = 26
	style.corner_radius_bottom_right = 26
	style.border_color = Color(0.34, 0.57, 0.74)
	style.set_border_width_all(4)
	add_theme_stylebox_override("panel", style)


func setup(task_data: Dictionary) -> void:
	task_id = String(task_data.get("id", task_id))
	correct_answer = int(task_data.get("answer", correct_answer))
	title_label.text = String(task_data.get("prompt", "How many shiny water drops can you count?"))


func _on_answer_pressed(answer: int) -> void:
	if answer == correct_answer:
		feedback_label.text = "You counted %d shiny drops. Splash-tastic!" % correct_answer
		continue_button.visible = true
		for button in answer_row.get_children():
			button.disabled = true
	else:
		feedback_label.text = "Let's count together: 1, 2, 3, 4, 5."


func _on_continue_button_pressed() -> void:
	emit_signal("task_finished", task_id, true)


func _on_close_button_pressed() -> void:
	emit_signal("closed")

