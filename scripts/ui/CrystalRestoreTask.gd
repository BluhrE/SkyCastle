extends PanelContainer

signal task_finished(task_id, success)
signal closed

@onready var title_label = $MarginContainer/VBoxContainer/TopRow/TitleLabel
@onready var feedback_label = $MarginContainer/VBoxContainer/FeedbackLabel
@onready var crystal_piece = $MarginContainer/VBoxContainer/PlayArea/CrystalPiece
@onready var crystal_socket = $MarginContainer/VBoxContainer/PlayArea/CrystalSocket
@onready var continue_button = $MarginContainer/VBoxContainer/ContinueButton

var task_id := "restore_song"


func _ready() -> void:
	_apply_style()
	continue_button.visible = false
	crystal_piece.piece_released.connect(_on_piece_released)


func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.96, 0.9, 0.98)
	style.corner_radius_top_left = 26
	style.corner_radius_top_right = 26
	style.corner_radius_bottom_left = 26
	style.corner_radius_bottom_right = 26
	style.border_color = Color(0.82, 0.63, 0.3)
	style.set_border_width_all(4)
	add_theme_stylebox_override("panel", style)
	var socket_style := StyleBoxFlat.new()
	socket_style.bg_color = Color(1.0, 0.93, 0.67)
	socket_style.border_color = Color(0.86, 0.62, 0.22)
	socket_style.corner_radius_top_left = 40
	socket_style.corner_radius_top_right = 40
	socket_style.corner_radius_bottom_left = 40
	socket_style.corner_radius_bottom_right = 40
	socket_style.set_border_width_all(4)
	crystal_socket.add_theme_stylebox_override("panel", socket_style)


func setup(task_data: Dictionary) -> void:
	task_id = String(task_data.get("id", task_id))
	title_label.text = String(task_data.get("prompt", "Drag the sparkling crystal to the glowing stand."))


func _on_piece_released(piece: TextureRect) -> void:
	var socket_rect := Rect2(crystal_socket.global_position, crystal_socket.size)
	var piece_rect := Rect2(piece.global_position, piece.size)
	if socket_rect.intersects(piece_rect):
		piece.global_position = crystal_socket.global_position + ((crystal_socket.size - piece.size) * 0.5)
		piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
		feedback_label.text = "The waterfall song is coming back!"
		continue_button.visible = true
	else:
		piece.reset_to_home()
		feedback_label.text = "Place the crystal on the glowing stand."


func _on_continue_button_pressed() -> void:
	emit_signal("task_finished", task_id, true)


func _on_close_button_pressed() -> void:
	emit_signal("closed")
