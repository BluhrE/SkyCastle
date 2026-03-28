extends Node2D

enum ChapterState {
	DIALOGUE,
	GAMEPLAY,
	TASK_ACTIVE,
	PAUSED,
	TRANSITION
}

const MAP_SCENE := "res://scenes/map/MapRoom.tscn"

@onready var dialogue = $CanvasLayer/DialogueBubble
@onready var hint_panel = $CanvasLayer/HintPanel
@onready var task_host = $CanvasLayer/TaskHost
@onready var progress_label = $CanvasLayer/ChapterBanner/ProgressLabel
@onready var map_button = $CanvasLayer/ReturnToMapButton
@onready var pause_overlay = $CanvasLayer/PauseOverlay
@onready var pause_menu = $CanvasLayer/PauseOverlay/PauseMenu
@onready var layer_debug_label = $CanvasLayer/LayerDebugLabel
@onready var count_button = $PlayLayer/CountDropsSpot
@onready var match_button = $PlayLayer/MatchFlowersSpot
@onready var sequence_button = $PlayLayer/SplashStonesSpot
@onready var drag_button = $PlayLayer/DragSparklesSpot
@onready var final_button = $PlayLayer/CrystalLedgeSpot

var dialogue_mode := ""
var chapter_state := ChapterState.DIALOGUE
var return_state_after_pause := ChapterState.GAMEPLAY
var active_task_id := ""
var active_task_panel: Control
var hotspots_visible := true


func _ready() -> void:
	GameState.mark_world_visited("waterfall")
	QuestManager.start_world("waterfall")
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
	_store_base_texts()
	_setup_hotspots()
	task_host.visible = false
	task_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_overlay.visible = false
	layer_debug_label.visible = false
	_update_layer_debug_text()
	_update_scene_state()
	if not GameState.save_data.get("waterfall_intro_seen", false):
		dialogue_mode = "waterfall_intro"
		GameState.mark_waterfall_intro_seen()
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


func _store_base_texts() -> void:
	for button in [count_button, match_button, sequence_button, drag_button, final_button]:
		button.set_meta("base_text", button.text)


func _setup_hotspots() -> void:
	for button in [count_button, match_button, sequence_button, drag_button, final_button]:
		button.mouse_entered.connect(_on_hotspot_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_hotspot_mouse_exited.bind(button))
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _set_chapter_state(new_state: int) -> void:
	chapter_state = new_state
	print("[Waterfall] Chapter state -> ", _chapter_state_name(new_state))
	pause_overlay.visible = new_state == ChapterState.PAUSED
	if new_state == ChapterState.PAUSED:
		pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		pause_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_scene_state()


func _update_scene_state() -> void:
	var completed_tasks := GameState.get_completed_tasks("waterfall")
	var completed_count := completed_tasks.size()
	progress_label.text = "Bibi's sparkle tasks: %d / 5" % completed_count
	var gameplay_active := chapter_state == ChapterState.GAMEPLAY
	_configure_hotspot(count_button, "count_drops", gameplay_active, true)
	_configure_hotspot(match_button, "match_flowers", gameplay_active, true)
	_configure_hotspot(sequence_button, "splash_sequence", gameplay_active, true)
	_configure_hotspot(drag_button, "drag_sparkles", gameplay_active, true)
	var final_ready := QuestManager.are_core_tasks_complete() and not GameState.has_completed_task("waterfall", "restore_song")
	_configure_hotspot(final_button, "restore_song", gameplay_active, final_ready)
	map_button.disabled = chapter_state in [ChapterState.DIALOGUE, ChapterState.TRANSITION]
	if chapter_state == ChapterState.GAMEPLAY:
		hint_panel.set_hint(HintManager.get_hint("waterfall"))


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


func _configure_hotspot(button: Button, task_id: String, gameplay_active: bool, available: bool) -> void:
	var is_done := GameState.has_completed_task("waterfall", task_id)
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
	print("[Waterfall] Opening task: ", task_id)
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
	hint_panel.set_hint(String(task.get("hint", "Take your time and play with the sparkles.")))


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
	print("[Debug] Hotspot visibility -> ", hotspots_visible)
	_update_scene_state()


func _debug_unlock_puzzles() -> void:
	print("[Debug] Unlocking waterfall core puzzles.")
	_close_task_panel()
	for task in QuestManager.get_tasks(false):
		var task_dict: Dictionary = task
		var task_id := String(task_dict.get("id", ""))
		if not GameState.has_completed_task("waterfall", task_id):
			GameState.mark_task_complete("waterfall", task_id, 0)
	_update_scene_state()
	hint_panel.set_hint("Debug: all core waterfall puzzles are now marked complete.")


func _debug_complete_current_puzzle() -> void:
	if active_task_id.is_empty():
		print("[Debug] No active puzzle to complete.")
		return
	print("[Debug] Completing active puzzle: ", active_task_id)
	_on_task_panel_finished(active_task_id, true)


func _debug_reset_save() -> void:
	print("[Debug] Resetting save and returning to the main menu.")
	GameState.reset_progress(true)
	SceneRouter.go_to_main_menu()


func _toggle_layer_debug() -> void:
	layer_debug_label.visible = not layer_debug_label.visible
	_update_layer_debug_text()
	print("[Debug] Layer overlay -> ", layer_debug_label.visible)


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
	var was_completed := GameState.is_world_completed("waterfall")
	var did_complete := QuestManager.complete_task(task_id)
	if task_id == "restore_song" and did_complete and not was_completed:
		dialogue_mode = "waterfall_complete"
		_set_chapter_state(ChapterState.DIALOGUE)
		dialogue.show_lines(DialogueLibrary.get_lines(dialogue_mode))
		return
	_set_chapter_state(ChapterState.GAMEPLAY)


func _on_task_panel_closed() -> void:
	print("[Waterfall] Closed task without completion: ", active_task_id)
	_close_task_panel()
	_set_chapter_state(ChapterState.GAMEPLAY)


func _on_task_completed(world_id: String, task_id: String) -> void:
	if world_id != "waterfall":
		return
	print("[Waterfall] Task completed callback: ", task_id)
	_update_scene_state()


func _on_core_tasks_ready(world_id: String) -> void:
	if world_id != "waterfall":
		return
	print("[Waterfall] Final restoration task is now available.")
	_update_scene_state()
	hint_panel.set_hint("All four helper spots are glowing. Visit the crystal ledge to restore the waterfall song.")


func _on_world_completed(world_id: String) -> void:
	if world_id != "waterfall":
		return
	print("[Waterfall] World completion callback received.")
	_update_scene_state()


func _on_dialogue_finished() -> void:
	if dialogue_mode == "waterfall_complete":
		dialogue_mode = ""
		_set_chapter_state(ChapterState.TRANSITION)
		SceneRouter.go_to("res://scenes/rewards/RewardScene.tscn", {"world_id": "waterfall"})
		return
	dialogue_mode = ""
	_set_chapter_state(ChapterState.GAMEPLAY)


func _on_count_drops_spot_pressed() -> void:
	_open_task("count_drops")


func _on_match_flowers_spot_pressed() -> void:
	_open_task("match_flowers")


func _on_splash_stones_spot_pressed() -> void:
	_open_task("splash_sequence")


func _on_drag_sparkles_spot_pressed() -> void:
	_open_task("drag_sparkles")


func _on_crystal_ledge_spot_pressed() -> void:
	_open_task("restore_song")


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
