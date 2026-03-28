extends PanelContainer

@onready var label = $MarginContainer/HintLabel


func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.99, 0.99, 0.99, 0.96)
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_left = 24
	style.corner_radius_bottom_right = 24
	style.border_color = Color(0.08, 0.08, 0.08, 1.0)
	style.set_border_width_all(2)
	add_theme_stylebox_override("panel", style)
	label.add_theme_color_override("font_color", Color(0.03, 0.03, 0.03))


func set_hint(text: String) -> void:
	label.text = text
