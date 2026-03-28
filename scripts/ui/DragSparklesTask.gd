extends PanelContainer

signal task_finished(task_id, success)
signal closed

@onready var title_label = $MarginContainer/VBoxContainer/TopRow/TitleLabel
@onready var feedback_label = $MarginContainer/VBoxContainer/FeedbackLabel
@onready var sparkle_row = $MarginContainer/VBoxContainer/PlayArea/SparkleRow
@onready var target_row = $MarginContainer/VBoxContainer/PlayArea/TargetRow
@onready var continue_button = $MarginContainer/VBoxContainer/ContinueButton

var task_id := "drag_sparkles"
var filled_targets: Array = []


func _ready() -> void:
	_apply_style()
	continue_button.visible = false
	for sparkle in sparkle_row.get_children():
		sparkle.piece_released.connect(_on_piece_released)


func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.97, 1.0, 0.98)
	style.corner_radius_top_left = 26
	style.corner_radius_top_right = 26
	style.corner_radius_bottom_left = 26
	style.corner_radius_bottom_right = 26
	style.border_color = Color(0.48, 0.52, 0.86)
	style.set_border_width_all(4)
	add_theme_stylebox_override("panel", style)
	for target in target_row.get_children():
		var ring_style := StyleBoxFlat.new()
		ring_style.bg_color = Color(0.85, 0.96, 1.0)
		ring_style.border_color = Color(0.43, 0.72, 0.92)
		ring_style.corner_radius_top_left = 48
		ring_style.corner_radius_top_right = 48
		ring_style.corner_radius_bottom_left = 48
		ring_style.corner_radius_bottom_right = 48
		ring_style.set_border_width_all(4)
		target.add_theme_stylebox_override("panel", ring_style)


func setup(task_data: Dictionary) -> void:
	task_id = String(task_data.get("id", task_id))
	title_label.text = String(task_data.get("prompt", "Drag the bright sparkles into the stream rings."))


func _on_piece_released(piece: TextureRect) -> void:
	for target in target_row.get_children():
		if filled_targets.has(target.name):
			continue
		var target_rect := Rect2(target.global_position, target.size)
		var piece_rect := Rect2(piece.global_position, piece.size)
		if target_rect.intersects(piece_rect):
			piece.global_position = target.global_position + ((target.size - piece.size) * 0.5)
			piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
			filled_targets.append(target.name)
			feedback_label.text = "A sparkle hopped into the stream."
			if filled_targets.size() == target_row.get_child_count():
				feedback_label.text = "The stream is shimmering again!"
				continue_button.visible = true
			return
	piece.reset_to_home()
	feedback_label.text = "Try dropping the sparkle inside a stream ring."


func _on_continue_button_pressed() -> void:
	emit_signal("task_finished", task_id, true)


func _on_close_button_pressed() -> void:
	emit_signal("closed")

