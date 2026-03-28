extends PanelContainer

signal resume_pressed
signal return_to_map_pressed
signal main_menu_pressed
signal quit_pressed

@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var resume_button = $MarginContainer/VBoxContainer/ResumeButton
@onready var return_to_map_button = $MarginContainer/VBoxContainer/ReturnToMapButton
@onready var main_menu_button = $MarginContainer/VBoxContainer/MainMenuButton
@onready var quit_button = $MarginContainer/VBoxContainer/QuitButton


func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.97, 0.91, 0.98)
	style.corner_radius_top_left = 32
	style.corner_radius_top_right = 32
	style.corner_radius_bottom_left = 32
	style.corner_radius_bottom_right = 32
	style.border_color = Color(0.63, 0.44, 0.31)
	style.set_border_width_all(4)
	style.shadow_size = 12
	style.shadow_color = Color(0.25, 0.17, 0.22, 0.22)
	add_theme_stylebox_override("panel", style)


func configure(config: Dictionary) -> void:
	title_label.text = String(config.get("title", "Pause"))
	resume_button.visible = bool(config.get("show_resume", true))
	return_to_map_button.visible = bool(config.get("show_return_to_map", false))
	main_menu_button.visible = bool(config.get("show_main_menu", true))
	quit_button.visible = bool(config.get("show_quit", true))
	resume_button.text = String(config.get("resume_text", "Resume"))
	return_to_map_button.text = String(config.get("return_to_map_text", "Return to Map"))
	main_menu_button.text = String(config.get("main_menu_text", "Main Menu"))
	quit_button.text = String(config.get("quit_text", "Quit Game"))


func _on_resume_button_pressed() -> void:
	emit_signal("resume_pressed")


func _on_return_to_map_button_pressed() -> void:
	emit_signal("return_to_map_pressed")


func _on_main_menu_button_pressed() -> void:
	emit_signal("main_menu_pressed")


func _on_quit_button_pressed() -> void:
	emit_signal("quit_pressed")
