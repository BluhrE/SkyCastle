extends PanelContainer

signal task_finished(task_id, success)
signal closed

@onready var title_label = $MarginContainer/VBoxContainer/TopRow/TitleLabel
@onready var feedback_label = $MarginContainer/VBoxContainer/FeedbackLabel
@onready var flower_row = $MarginContainer/VBoxContainer/FlowerRow
@onready var target_row = $MarginContainer/VBoxContainer/TargetRow
@onready var continue_button = $MarginContainer/VBoxContainer/ContinueButton

var task_id := "match_flowers"
var selected_flower := ""
var matches := {
	"pink": "pink",
	"blue": "blue",
	"gold": "gold"
}
var node_names := {
	"pink": "Pink",
	"blue": "Blue",
	"gold": "Gold"
}
var made_matches: Array = []


func _ready() -> void:
	_apply_style()
	continue_button.visible = false
	for flower in flower_row.get_children():
		flower.pressed.connect(_on_flower_pressed.bind(String(flower.name).to_lower()))
	for target in target_row.get_children():
		target.pressed.connect(_on_target_pressed.bind(String(target.name).replace("Target", "").to_lower()))


func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.96, 0.98, 0.98)
	style.corner_radius_top_left = 26
	style.corner_radius_top_right = 26
	style.corner_radius_bottom_left = 26
	style.corner_radius_bottom_right = 26
	style.border_color = Color(0.82, 0.42, 0.63)
	style.set_border_width_all(4)
	add_theme_stylebox_override("panel", style)


func setup(task_data: Dictionary) -> void:
	task_id = String(task_data.get("id", task_id))
	title_label.text = String(task_data.get("prompt", "Match each sleepy flower with its shining blossom ring."))


func _on_flower_pressed(flower_id: String) -> void:
	if made_matches.has(flower_id):
		return
	selected_flower = flower_id
	feedback_label.text = "Now click the matching blossom ring."


func _on_target_pressed(target_id: String) -> void:
	if selected_flower.is_empty():
		feedback_label.text = "Pick a flower first."
		return
	if target_id == matches.get(selected_flower, ""):
		made_matches.append(selected_flower)
		var flower_button: Button = flower_row.get_node(node_names.get(selected_flower, "Pink"))
		var target_button: Button = target_row.get_node("%sTarget" % node_names.get(target_id, "Pink"))
		flower_button.disabled = true
		target_button.disabled = true
		target_button.text = "Bloom!"
		feedback_label.text = "That flower woke right up."
		selected_flower = ""
		if made_matches.size() == matches.size():
			feedback_label.text = "All the water flowers are shining!"
			continue_button.visible = true
	else:
		feedback_label.text = "That one looks different. Try another blossom ring."
		selected_flower = ""


func _on_continue_button_pressed() -> void:
	emit_signal("task_finished", task_id, true)


func _on_close_button_pressed() -> void:
	emit_signal("closed")
