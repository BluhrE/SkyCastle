extends Node2D

enum ChapterState {
	DIALOGUE,
	GAMEPLAY,
	TASK_ACTIVE,
	PAUSED,
	TRANSITION
}

const MAP_SCENE := "res://scenes/map/MapRoom.tscn"

@export var world_id := "forest"

@onready var background_art = $Background/BackgroundArt
@onready var midground_art = $Midground/SetpieceArt
@onready var foreground_art = $Foreground/ForegroundArt
@onready var friend_art = $Characters/FriendArt
@onready var friend_name_label = $Characters/FriendName
@onready var world_title_label = $CanvasLayer/ChapterBanner/MarginContainer/HBoxContainer/WorldTitle
@onready var progress_label = $CanvasLayer/ChapterBanner/MarginContainer/HBoxContainer/ProgressLabel
@onready var dialogue = $CanvasLayer/DialogueBubble
@onready var hint_panel = $CanvasLayer/HintPanel
@onready var task_host = $CanvasLayer/TaskHost
@onready var map_button = $CanvasLayer/ReturnToMapButton
@onready var pause_overlay = $CanvasLayer/PauseOverlay
@onready var pause_menu = $CanvasLayer/PauseOverlay/PauseMenu
@onready var layer_debug_label = $CanvasLayer/LayerDebugLabel
@onready var spot_buttons := [
	$PlayLayer/CoreSpot1,
	$PlayLayer/CoreSpot2,
	$PlayLayer/CoreSpot3,
	$PlayLayer/CoreSpot4
]
@onready var final_button = $PlayLayer/FinalSpot

var dialogue_mode := ""
var chapter_state := ChapterState.DIALOGUE
var return_state_after_pause := ChapterState.GAMEPLAY
var active_task_id := ""
var active_task_panel: Control
var hotspots_visible := true
var final_task_id := ""


func _ready() -> void:
	var payload := SceneRouter.take_payload()
	if String(payload.get("world_id", "")).length() > 0:
		world_id = String(payload.get("world_id"))
	var world: Dictionary = WorldLibrary.get_world(world_id)
	_apply_world_art(world)
	world_title_label.text = String(world.get("name", world_id.capitalize()))
	GameState.mark_world_visited(world_id)
	QuestManager.start_world(world_id)
	dialogue.dialogue_finished.connect(_on_dialogue_finished)
	QuestManager.task_completed.connect(_on_task_completed)
	QuestManager.core_tasks_ready.connect(_on_core_tasks_ready)
	QuestManager.world_completed.connect(_on_world_completed)
	pause_menu.resume_pressed.connect(_on_pause_resume_pressed)
	pause_menu.return_to_map_pressed.connect(_on_pause_return_to_map_pressed)
	pause_menu.main_menu_pressed.connect(_on_pause_main_menu_pressed)
	pause_menu.quit_pressed.connect(_on_pause_quit_pressed)
	pause_menu.configure({
		"title": "Adventure Menu",
		"show_resume": true,
		"show_return_to_map": true,
		"show_main_menu": true,
		"show_quit": true
	})
	_setup_hotspots()
	_load_task_button_text()
	task_host.visible = false
	task_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_overlay.visible = false
	layer_debug_label.visible = false
	_update_layer_debug_text()
	_update_scene_state()
	if not GameState.has_seen_world_intro(world_id):
		dialogue_mode = "%s_intro" % world_id
		GameState.mark_world_intro_seen(world_id)
		_set_chapter_state(ChapterState.DIALOGUE)
		dialogue.show_lines(DialogueLibrary.get_lines(dialogue_mode))
	else:
		_set_chapter_state(ChapterState.GAMEPLAY)


func _exit_tree() -> void:
	if QuestManager.task_completed.is_connected(_on_task_completed):
		QuestManager.task_completed.disconnect(_on_task_completed)
	if QuestManager.core_tasks_ready.is_connected(_on_core_tasks_ready):
		QuestManager.core_tasks_ready.disconnect(_on_core_tasks_ready)
	if QuestManager.world_completed.is_connected(_on_world_completed):
		QuestManager.world_completed.disconnect(_on_world_completed)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				if chapter_state in [ChapterState.GAMEPLAY, ChapterState.TASK_ACTIVE, ChapterState.PAUSED]:
					if chapter_state == ChapterState.PAUSED:
						_close_pause_menu()
					else:
						_open_pause_menu()
					get_viewport().set_input_as_handled()
			KEY_F1:
				if OS.is_debug_build():
					_toggle_hotspots_debug()
					get_viewport().set_input_as_handled()
			KEY_F2:
				if OS.is_debug_build():
					_debug_unlock_puzzles()
					get_viewport().set_input_as_handled()
			KEY_F3:
				if OS.is_debug_build():
					_debug_complete_current_puzzle()
					get_viewport().set_input_as_handled()
			KEY_F4:
				if OS.is_debug_build():
					_debug_reset_save()
					get_viewport().set_input_as_handled()
			KEY_F5:
				if OS.is_debug_build():
					_toggle_layer_debug()
					get_viewport().set_input_as_handled()


func _setup_hotspots() -> void:
	for button in spot_buttons:
		button.mouse_entered.connect(_on_hotspot_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_hotspot_mouse_exited.bind(button))
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	final_button.mouse_entered.connect(_on_hotspot_mouse_entered.bind(final_button))
	final_button.mouse_exited.connect(_on_hotspot_mouse_exited.bind(final_button))
	final_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _load_task_button_text() -> void:
	var core_tasks := QuestManager.get_tasks(false)
	for index in range(spot_buttons.size()):
		var button: Button = spot_buttons[index]
		if index < core_tasks.size():
			var task_dict: Dictionary = core_tasks[index]
			var task_id := String(task_dict.get("id", ""))
			var button_text := String(task_dict.get("button_text", task_dict.get("name", "Helper Spot")))
			button.set_meta("task_id", task_id)
			button.set_meta("base_text", button_text)
			button.text = button_text
		else:
			button.set_meta("task_id", "")
			button.set_meta("base_text", "Coming Soon")
			button.text = "Coming Soon"
			button.disabled = true
	var final_task := _get_final_task()
	final_task_id = String(final_task.get("id", ""))
	final_button.set_meta("task_id", final_task_id)
	final_button.set_meta("base_text", String(final_task.get("button_text", final_task.get("name", "Final Glow"))))
	final_button.text = String(final_button.get_meta("base_text"))


func _apply_world_art(world: Dictionary) -> void:
	var background_path := String(world.get("background_texture", ""))
	var midground_path := String(world.get("midground_texture", ""))
	var foreground_path := String(world.get("foreground_texture", ""))
	var friend_path := String(world.get("friend_texture", ""))
	if not background_path.is_empty():
		background_art.texture = load(background_path)
	if not midground_path.is_empty():
		midground_art.texture = load(midground_path)
	if not foreground_path.is_empty():
		foreground_art.texture = load(foreground_path)
	if not friend_path.is_empty():
		friend_art.texture = load(friend_path)
	friend_name_label.text = String(world.get("friend", "Friend Helper"))


func _get_final_task() -> Dictionary:
	for task in QuestManager.get_tasks(true):
		var task_dict: Dictionary = task
		if String(task_dict.get("type", "")) == "final":
			return task_dict
	return {}


func _set_chapter_state(new_state: int) -> void:
	chapter_state = new_state
	print("[%s] Chapter state -> %s" % [world_id.capitalize(), _chapter_state_name(new_state)])
	pause_overlay.visible = new_state == ChapterState.PAUSED
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP if pause_overlay.visible else Control.MOUSE_FILTER_IGNORE
	_update_scene_state()


func _chapter_state_name(value: int) -> String:
	match value:
		ChapterState.DIALOGUE:
			return "DIALOGUE"
		ChapterState.GAMEPLAY:
			return "GAMEPLAY"
		ChapterState.TASK_ACTIVE:
			return "TASK_ACTIVE"
		ChapterState.PAUSED:
			return "PAUSED"
		ChapterState.TRANSITION:
			return "TRANSITION"
	return "UNKNOWN"


func _update_scene_state() -> void:
	var completed_tasks := GameState.get_completed_tasks(world_id)
	progress_label.text = "Helper tasks: %d / 5" % completed_tasks.size()
	var gameplay_active := chapter_state == ChapterState.GAMEPLAY
	for button in spot_buttons:
		var task_id := String(button.get_meta("task_id", ""))
		if task_id.is_empty():
			button.disabled = true
			continue
		_configure_hotspot(button, task_id, gameplay_active, true)
	var final_ready := QuestManager.are_core_tasks_complete() and not GameState.has_completed_task(world_id, final_task_id)
	_configure_hotspot(final_button, final_task_id, gameplay_active, final_ready)
	map_button.disabled = chapter_state in [ChapterState.DIALOGUE, ChapterState.TRANSITION]
	if chapter_state == ChapterState.GAMEPLAY:
		hint_panel.set_hint(HintManager.get_hint(world_id))


func _configure_hotspot(button: Button, task_id: String, gameplay_active: bool, available: bool) -> void:
	var is_done := GameState.has_completed_task(world_id, task_id)
	var base_text := String(button.get_meta("base_text", button.text))
	button.text = "%s\nDone!" % base_text if is_done else base_text
	button.disabled = is_done or not gameplay_active or not available
	button.modulate = _hotspot_color(is_done, available and gameplay_active, false)


func _hotspot_color(is_done: bool, is_available: bool, is_hovered: bool) -> Color:
	if is_done:
		return Color(0.76, 0.97, 0.8, 0.95 if hotspots_visible else 0.55)
	if not is_available:
		return Color(0.78, 0.78, 0.78, 0.45 if hotspots_visible else 0.22)
	if is_hovered:
		return Color(1.0, 0.98, 0.82, 1.0)
	return Color(1.0, 1.0, 1.0, 0.92 if hotspots_visible else 0.3)


func _open_task(task_id: String) -> void:
	if chapter_state != ChapterState.GAMEPLAY:
		return
	if task_host.get_child_count() > 0:
		return
	var task: Dictionary = QuestManager.get_task(task_id)
	if task.is_empty():
		return
	var scene := load(String(task.get("scene", "")))
	if scene == null:
		return
	active_task_id = task_id
	print("[%s] Opening task: %s" % [world_id.capitalize(), task_id])
	task_host.visible = true
	task_host.mouse_filter = Control.MOUSE_FILTER_STOP
	var task_panel = scene.instantiate()
	active_task_panel = task_panel
	task_host.add_child(task_panel)
	if task_panel.has_method("setup"):
		task_panel.setup(task)
	task_panel.task_finished.connect(_on_task_panel_finished)
	task_panel.closed.connect(_on_task_panel_closed)
	_set_chapter_state(ChapterState.TASK_ACTIVE)
	hint_panel.set_hint(String(task.get("hint", "Take your time and help one sparkle at a time.")))


func _close_task_panel() -> void:
	if active_task_panel != null:
		active_task_panel.queue_free()
	active_task_panel = null
	active_task_id = ""
	task_host.visible = false
	task_host.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _open_pause_menu() -> void:
	if chapter_state in [ChapterState.DIALOGUE, ChapterState.TRANSITION]:
		return
	return_state_after_pause = chapter_state
	_set_chapter_state(ChapterState.PAUSED)


func _close_pause_menu() -> void:
	if return_state_after_pause == ChapterState.TASK_ACTIVE and active_task_panel != null:
		_set_chapter_state(ChapterState.TASK_ACTIVE)
	else:
		_set_chapter_state(ChapterState.GAMEPLAY)


func _return_to_map() -> void:
	_close_task_panel()
	_set_chapter_state(ChapterState.TRANSITION)
	SceneRouter.go_to(MAP_SCENE, {})


func _toggle_hotspots_debug() -> void:
	hotspots_visible = not hotspots_visible
	print("[Debug] %s hotspot visibility -> %s" % [world_id, hotspots_visible])
	_update_scene_state()


func _debug_unlock_puzzles() -> void:
	print("[Debug] Unlocking %s core puzzles." % world_id)
	_close_task_panel()
	for task in QuestManager.get_tasks(false):
		var task_dict: Dictionary = task
		var task_id := String(task_dict.get("id", ""))
		if not GameState.has_completed_task(world_id, task_id):
			GameState.mark_task_complete(world_id, task_id, 0)
	_update_scene_state()
	hint_panel.set_hint("Debug: all core %s puzzles are now marked complete." % world_id)


func _debug_complete_current_puzzle() -> void:
	if active_task_id.is_empty():
		print("[Debug] No active puzzle to complete.")
		return
	print("[Debug] Completing active puzzle: %s" % active_task_id)
	_on_task_panel_finished(active_task_id, true)


func _debug_reset_save() -> void:
	print("[Debug] Resetting save and returning to the main menu.")
	GameState.reset_progress(true)
	SceneRouter.go_to_main_menu()


func _toggle_layer_debug() -> void:
	layer_debug_label.visible = not layer_debug_label.visible
	_update_layer_debug_text()
	print("[Debug] Layer overlay -> %s" % layer_debug_label.visible)


func _update_layer_debug_text() -> void:
	layer_debug_label.text = "Layer Debug\nBackground z0\nMidground z1\nPlay Layer z3\nCharacters z4\nForeground z5\nUI CanvasLayer"


func _on_hotspot_mouse_entered(button: Button) -> void:
	if button.disabled:
		return
	button.scale = Vector2(1.04, 1.04)
	button.modulate = _hotspot_color(false, true, true)


func _on_hotspot_mouse_exited(button: Button) -> void:
	button.scale = Vector2.ONE
	_update_scene_state()


func _on_task_panel_finished(task_id: String, success: bool) -> void:
	if not success:
		return
	_close_task_panel()
	var was_completed := GameState.is_world_completed(world_id)
	var did_complete := QuestManager.complete_task(task_id)
	if task_id == final_task_id and did_complete and not was_completed:
		dialogue_mode = "%s_complete" % world_id
		_set_chapter_state(ChapterState.DIALOGUE)
		dialogue.show_lines(DialogueLibrary.get_lines(dialogue_mode))
		return
	_set_chapter_state(ChapterState.GAMEPLAY)


func _on_task_panel_closed() -> void:
	print("[%s] Closed task without completion: %s" % [world_id.capitalize(), active_task_id])
	_close_task_panel()
	_set_chapter_state(ChapterState.GAMEPLAY)


func _on_task_completed(event_world_id: String, task_id: String) -> void:
	if event_world_id != world_id:
		return
	print("[%s] Task completed callback: %s" % [world_id.capitalize(), task_id])
	_update_scene_state()


func _on_core_tasks_ready(event_world_id: String) -> void:
	if event_world_id != world_id:
		return
	print("[%s] Final restoration task is now available." % world_id.capitalize())
	_update_scene_state()
	hint_panel.set_hint("All the helper spots are glowing. Visit the final sparkle place to finish this chapter.")


func _on_world_completed(event_world_id: String) -> void:
	if event_world_id != world_id:
		return
	print("[%s] World completion callback received." % world_id.capitalize())
	_update_scene_state()


func _on_dialogue_finished() -> void:
	if dialogue_mode == "%s_complete" % world_id:
		dialogue_mode = ""
		_set_chapter_state(ChapterState.TRANSITION)
		SceneRouter.go_to("res://scenes/rewards/RewardScene.tscn", {"world_id": world_id})
		return
	dialogue_mode = ""
	_set_chapter_state(ChapterState.GAMEPLAY)


func _on_core_spot_1_pressed() -> void:
	_open_spot_task(0)


func _on_core_spot_2_pressed() -> void:
	_open_spot_task(1)


func _on_core_spot_3_pressed() -> void:
	_open_spot_task(2)


func _on_core_spot_4_pressed() -> void:
	_open_spot_task(3)


func _open_spot_task(index: int) -> void:
	if index >= spot_buttons.size():
		return
	var task_id := String(spot_buttons[index].get_meta("task_id", ""))
	if task_id.is_empty():
		return
	_open_task(task_id)


func _on_final_spot_pressed() -> void:
	_open_task(final_task_id)


func _on_return_to_map_button_pressed() -> void:
	_return_to_map()


func _on_pause_resume_pressed() -> void:
	_close_pause_menu()


func _on_pause_return_to_map_pressed() -> void:
	_return_to_map()


func _on_pause_main_menu_pressed() -> void:
	_close_task_panel()
	_set_chapter_state(ChapterState.TRANSITION)
	SceneRouter.go_to_main_menu()


func _on_pause_quit_pressed() -> void:
	_close_task_panel()
	get_tree().quit()
