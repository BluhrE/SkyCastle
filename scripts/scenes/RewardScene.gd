extends Node2D

@onready var reward_panel = $CanvasLayer/RewardPanel
@onready var pause_overlay = $CanvasLayer/PauseOverlay
@onready var pause_menu = $CanvasLayer/PauseOverlay/PauseMenu

var world_id := "waterfall"
var map_dialogue_id := "map_after_waterfall"


func _ready() -> void:
	var payload := SceneRouter.take_payload()
	world_id = String(payload.get("world_id", "waterfall"))
	map_dialogue_id = "map_after_%s" % world_id
	var reward_data := _get_reward_data(world_id)
	reward_panel.set_reward_data(world_id, reward_data, GameState.get_heart_stars(), GameState.get_ribbon_total())
	reward_panel.continue_pressed.connect(_on_continue_pressed)
	pause_menu.resume_pressed.connect(_on_pause_resume_pressed)
	pause_menu.return_to_map_pressed.connect(_on_pause_return_to_map_pressed)
	pause_menu.main_menu_pressed.connect(_on_pause_main_menu_pressed)
	pause_menu.quit_pressed.connect(_on_pause_quit_pressed)
	pause_menu.configure({
		"title": "Reward Menu",
		"show_resume": true,
		"resume_text": "Back to Reward",
		"show_return_to_map": true,
		"show_main_menu": true,
		"show_quit": true
	})
	pause_overlay.visible = false
	GameState.mark_world_reward_seen(world_id)
	GameState.save_game()


func _get_reward_data(world_id: String) -> Dictionary:
	var file := FileAccess.open("res://data/rewards/rewards.json", FileAccess.READ)
	if not file:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {}
	return parsed.get(world_id, {})


func _on_continue_pressed() -> void:
	SceneRouter.go_to("res://scenes/map/MapRoom.tscn", {"dialogue": map_dialogue_id})


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		pause_overlay.visible = not pause_overlay.visible
		get_viewport().set_input_as_handled()


func _on_pause_resume_pressed() -> void:
	pause_overlay.visible = false


func _on_pause_main_menu_pressed() -> void:
	SceneRouter.go_to_main_menu()


func _on_pause_return_to_map_pressed() -> void:
	_on_continue_pressed()


func _on_pause_quit_pressed() -> void:
	get_tree().quit()
