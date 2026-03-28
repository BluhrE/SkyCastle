extends PanelContainer

signal task_finished(task_id, success)
signal closed

const DEFAULT_TOKEN_TEXTURE := preload("res://assets/art/first_slice/props/waterfall/prop_task_crystal_piece.svg")
const DEFAULT_SOCKET_TEXTURE := preload("res://assets/art/first_slice/props/waterfall/prop_task_crystal_socket.svg")

@onready var title_label = $MarginContainer/VBoxContainer/TopRow/TitleLabel
@onready var feedback_label = $MarginContainer/VBoxContainer/FeedbackLabel
@onready var socket_panel = $MarginContainer/VBoxContainer/PlayArea/SocketPanel
@onready var socket_art = $MarginContainer/VBoxContainer/PlayArea/SocketPanel/SocketArt
@onready var socket_label = $MarginContainer/VBoxContainer/PlayArea/SocketPanel/SocketLabel
@onready var token_piece = $MarginContainer/VBoxContainer/PlayArea/TokenPiece
@onready var token_label = $MarginContainer/VBoxContainer/PlayArea/TokenPiece/TokenLabel
@onready var continue_button = $MarginContainer/VBoxContainer/ContinueButton

var task_id := ""


func _ready() -> void:
	_apply_style()
	continue_button.visible = false
	token_piece.piece_released.connect(_on_piece_released)


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
	var socket_style := StyleBoxFlat.new()
	socket_style.bg_color = Color(0.99, 0.96, 0.85)
	socket_style.border_color = Color(0.79, 0.63, 0.24)
	socket_style.corner_radius_top_left = 42
	socket_style.corner_radius_top_right = 42
	socket_style.corner_radius_bottom_left = 42
	socket_style.corner_radius_bottom_right = 42
	socket_style.set_border_width_all(3)
	socket_panel.add_theme_stylebox_override("panel", socket_style)


func setup(task_data: Dictionary) -> void:
	task_id = String(task_data.get("id", "place_token"))
	title_label.text = String(task_data.get("prompt", "Drag the glowing helper into the shining place."))
	feedback_label.text = String(task_data.get("hint", "Place the glowing helper right on the shining place."))
	socket_label.text = String(task_data.get("socket_label", "Shining Place"))
	token_label.text = String(task_data.get("token_label", "Helper"))
	var token_path := String(task_data.get("token_texture", ""))
	var socket_path := String(task_data.get("socket_texture", ""))
	if token_path.is_empty():
		token_piece.texture = DEFAULT_TOKEN_TEXTURE
	else:
		token_piece.texture = load(token_path)
	if socket_path.is_empty():
		socket_art.texture = DEFAULT_SOCKET_TEXTURE
	else:
		socket_art.texture = load(socket_path)


func _on_piece_released(piece: TextureRect) -> void:
	var socket_rect := Rect2(socket_panel.global_position, socket_panel.size)
	var piece_rect := Rect2(piece.global_position, piece.size)
	if socket_rect.intersects(piece_rect):
		piece.global_position = socket_panel.global_position + ((socket_panel.size - piece.size) * 0.5)
		piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
		token_label.visible = false
		feedback_label.text = "You helped the world glow again!"
		continue_button.visible = true
	else:
		piece.reset_to_home()
		feedback_label.text = "Place the glowing helper right on the shining place."


func _on_continue_button_pressed() -> void:
	emit_signal("task_finished", task_id, true)


func _on_close_button_pressed() -> void:
	emit_signal("closed")
