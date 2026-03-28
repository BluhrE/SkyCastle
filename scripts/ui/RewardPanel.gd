extends PanelContainer

signal continue_pressed

@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var body_label = $MarginContainer/VBoxContainer/BodyLabel
@onready var star_panel = $MarginContainer/VBoxContainer/BadgeRow/StarBadge
@onready var ribbon_panel = $MarginContainer/VBoxContainer/BadgeRow/RibbonBadge
@onready var star_label = $MarginContainer/VBoxContainer/BadgeRow/StarBadge/Value
@onready var ribbon_label = $MarginContainer/VBoxContainer/BadgeRow/RibbonBadge/Value
@onready var total_label = $MarginContainer/VBoxContainer/TotalLabel


func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.97, 0.9, 0.97)
	style.corner_radius_top_left = 36
	style.corner_radius_top_right = 36
	style.corner_radius_bottom_left = 36
	style.corner_radius_bottom_right = 36
	style.border_color = Color(0.82, 0.58, 0.33)
	style.set_border_width_all(5)
	style.shadow_color = Color(0.56, 0.31, 0.43, 0.25)
	style.shadow_size = 16
	add_theme_stylebox_override("panel", style)
	_style_badge(star_panel, Color(1.0, 0.92, 0.56))
	_style_badge(ribbon_panel, Color(1.0, 0.77, 0.84))


func _style_badge(panel: PanelContainer, color: Color) -> void:
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = color
	badge_style.corner_radius_top_left = 28
	badge_style.corner_radius_top_right = 28
	badge_style.corner_radius_bottom_left = 28
	badge_style.corner_radius_bottom_right = 28
	badge_style.border_color = Color(0.58, 0.42, 0.26)
	badge_style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", badge_style)


func set_reward_data(world_id: String, reward_data: Dictionary, total_stars: int, total_ribbons: int) -> void:
	title_label.text = String(reward_data.get("title", "A world sparkled again!"))
	body_label.text = String(reward_data.get("message", "Sky helped Bibi and brought the waterfall song back."))
	star_label.text = "+%d Heart Stars" % int(reward_data.get("heart_stars", 0))
	ribbon_label.text = "Sunset Ribbon: 1" if bool(reward_data.get("sunset_ribbon", true)) else "Ribbon saved for later"
	total_label.text = "Total Heart Stars: %d    Total Ribbons: %d" % [total_stars, total_ribbons]


func _on_continue_button_pressed() -> void:
	emit_signal("continue_pressed")
