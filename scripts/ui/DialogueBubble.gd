extends PanelContainer

signal dialogue_finished

@onready var speaker_label = $MarginContainer/VBoxContainer/SpeakerLabel
@onready var text_label = $MarginContainer/VBoxContainer/TextLabel
@onready var continue_button = $MarginContainer/VBoxContainer/Footer/ContinueButton
@onready var voice_player = $VoicePlayer

var lines: Array = []
var current_index := -1


func _ready() -> void:
	_apply_style()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 20
	hide()


func _apply_style() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(1.0, 1.0, 1.0, 0.99)
	panel_style.corner_radius_top_left = 28
	panel_style.corner_radius_top_right = 28
	panel_style.corner_radius_bottom_left = 28
	panel_style.corner_radius_bottom_right = 28
	panel_style.border_color = Color(0.08, 0.08, 0.08, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.12)
	panel_style.shadow_size = 8
	add_theme_stylebox_override("panel", panel_style)
	speaker_label.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	text_label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0))
	continue_button.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0))


func show_lines(new_lines: Array) -> void:
	lines = new_lines.duplicate(true)
	current_index = -1
	voice_player.stop()
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
	_show_next_line()


func _show_next_line() -> void:
	current_index += 1
	if current_index >= lines.size():
		voice_player.stop()
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		hide()
		emit_signal("dialogue_finished")
		return
	var line: Dictionary = lines[current_index]
	speaker_label.text = String(line.get("speaker", "Friend"))
	text_label.text = String(line.get("text", ""))
	continue_button.text = "Let's go!" if current_index == lines.size() - 1 else "Next"
	_play_voice_for_line(line)


func _on_continue_button_pressed() -> void:
	_show_next_line()


func _play_voice_for_line(line: Dictionary) -> void:
	voice_player.stop()
	var voice_path := String(line.get("voice_path", ""))
	if voice_path.is_empty():
		return
	var stream := load(voice_path)
	if stream == null:
		push_warning("Dialogue voice clip could not be loaded: %s" % voice_path)
		return
	voice_player.stream = stream
	voice_player.volume_db = float(line.get("voice_volume_db", 0.0))
	voice_player.pitch_scale = float(line.get("voice_pitch_scale", 1.0))
	voice_player.play()
