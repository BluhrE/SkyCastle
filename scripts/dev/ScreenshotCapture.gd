extends Node

const VIEWPORT_SIZE := Vector2i(1280, 720)
const DEFAULT_CAPTURE_DIR := "res://debug/captures"
const CORE_TASK_IDS := ["count_drops", "match_flowers", "splash_sequence", "drag_sparkles"]
const CAPTURE_PROFILES := [
	{
		"id": "00_sky_concept_preview",
		"scene": "res://scenes/dev/SkyConceptPreview.tscn",
		"setup": "_prepare_main_menu_fresh"
	},
	{
		"id": "01_main_menu_fresh",
		"scene": "res://scenes/menu/MainMenu.tscn",
		"setup": "_prepare_main_menu_fresh"
	},
	{
		"id": "02_castle_intro_dialogue",
		"scene": "res://scenes/castle/CastleIntro.tscn",
		"setup": "_prepare_new_game_state"
	},
	{
		"id": "03_castle_intro_ready",
		"scene": "res://scenes/castle/CastleIntro.tscn",
		"setup": "_prepare_new_game_state",
		"stage": "_stage_castle_intro_ready"
	},
	{
		"id": "04_map_room_unlocked",
		"scene": "res://scenes/map/MapRoom.tscn",
		"setup": "_prepare_map_room_unlocked"
	},
	{
		"id": "05_waterfall_gameplay",
		"scene": "res://scenes/worlds/WaterfallWorld.tscn",
		"setup": "_prepare_waterfall_gameplay"
	},
	{
		"id": "06_reward_scene",
		"scene": "res://scenes/rewards/RewardScene.tscn",
		"setup": "_prepare_reward_scene"
	},
	{
		"id": "07_map_room_restored",
		"scene": "res://scenes/map/MapRoom.tscn",
		"setup": "_prepare_map_room_restored"
	},
	{
		"id": "08_forest_gameplay",
		"scene": "res://scenes/worlds/ForestWorld.tscn",
		"setup": "_prepare_forest_gameplay"
	},
	{
		"id": "09_beach_gameplay",
		"scene": "res://scenes/worlds/BeachWorld.tscn",
		"setup": "_prepare_beach_gameplay"
	},
	{
		"id": "10_zoo_gameplay",
		"scene": "res://scenes/worlds/ZooWorld.tscn",
		"setup": "_prepare_zoo_gameplay"
	},
	{
		"id": "11_house_gameplay",
		"scene": "res://scenes/worlds/HouseWorld.tscn",
		"setup": "_prepare_house_gameplay"
	}
]

var capture_viewport: SubViewport
var output_dir := DEFAULT_CAPTURE_DIR
var original_save_exists := false
var original_save_text := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	output_dir = _resolve_output_dir()
	_setup_viewport()
	_backup_save_state()
	await get_tree().process_frame
	print("[Capture] Starting capture run into ", output_dir)
	await _run_capture_profiles()
	_restore_save_state()
	print("[Capture] Capture run finished.")
	get_tree().quit()


func _setup_viewport() -> void:
	capture_viewport = SubViewport.new()
	capture_viewport.name = "CaptureViewport"
	capture_viewport.disable_3d = true
	capture_viewport.size = VIEWPORT_SIZE
	capture_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	capture_viewport.transparent_bg = false
	add_child(capture_viewport)


func _resolve_output_dir() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="):
			var requested := String(arg.trim_prefix("--capture-dir=")).strip_edges()
			if not requested.is_empty():
				return requested
	return DEFAULT_CAPTURE_DIR


func _backup_save_state() -> void:
	GameState.initialize()
	var absolute_save_path := ProjectSettings.globalize_path(GameState.SAVE_PATH)
	original_save_exists = FileAccess.file_exists(GameState.SAVE_PATH)
	if original_save_exists:
		var file := FileAccess.open(absolute_save_path, FileAccess.READ)
		if file:
			original_save_text = file.get_as_text()
	print("[Capture] Backed up save state. Existing save: ", original_save_exists)


func _restore_save_state() -> void:
	var absolute_save_path := ProjectSettings.globalize_path(GameState.SAVE_PATH)
	if original_save_exists:
		var file := FileAccess.open(absolute_save_path, FileAccess.WRITE)
		if file:
			file.store_string(original_save_text)
			print("[Capture] Restored original save file.")
	else:
		if FileAccess.file_exists(GameState.SAVE_PATH):
			var result := DirAccess.remove_absolute(absolute_save_path)
			print("[Capture] Removed temporary save file. Result: ", result)
	GameState.load_save()


func _run_capture_profiles() -> void:
	var absolute_output_dir := ProjectSettings.globalize_path(output_dir)
	DirAccess.make_dir_recursive_absolute(absolute_output_dir)
	for profile_data in CAPTURE_PROFILES:
		var profile: Dictionary = profile_data
		print("[Capture] Running profile: ", String(profile.get("id", "unknown")))
		await _capture_profile(profile, absolute_output_dir)


func _capture_profile(profile: Dictionary, absolute_output_dir: String) -> void:
	await _clear_viewport()
	_apply_profile_setup(String(profile.get("setup", "")))
	var scene_path := String(profile.get("scene", ""))
	var packed_scene: PackedScene = load(scene_path)
	if packed_scene == null:
		push_error("Capture scene could not be loaded: %s" % scene_path)
		return
	var scene_instance := packed_scene.instantiate()
	capture_viewport.add_child(scene_instance)
	print("[Capture] Added scene instance: ", scene_path)
	await _wait_frames(6)
	_apply_profile_stage(String(profile.get("stage", "")), scene_instance)
	await _wait_frames(6)
	await RenderingServer.frame_post_draw
	var image := capture_viewport.get_texture().get_image()
	if image == null:
		push_error("Capture image was null for profile %s" % String(profile.get("id", "unknown")))
		return
	var filename := "%s.png" % String(profile.get("id", "capture"))
	var save_path := absolute_output_dir.path_join(filename)
	var result := image.save_png(save_path)
	print("[Capture] Saved %s (result %s)" % [save_path, result])


func _clear_viewport() -> void:
	for child in capture_viewport.get_children():
		child.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


func _wait_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame


func _apply_profile_setup(method_name: String) -> void:
	if method_name.is_empty():
		return
	if has_method(method_name):
		call(method_name)


func _apply_profile_stage(method_name: String, scene_instance: Node) -> void:
	if method_name.is_empty():
		return
	if has_method(method_name):
		call(method_name, scene_instance)


func _prepare_main_menu_fresh() -> void:
	SceneRouter.pending_payload.clear()
	GameState.reset_progress(true)
	GameState.load_save()


func _prepare_new_game_state() -> void:
	SceneRouter.pending_payload.clear()
	GameState.begin_new_game()


func _prepare_map_room_unlocked() -> void:
	SceneRouter.pending_payload.clear()
	GameState.begin_new_game()
	GameState.mark_intro_seen()
	GameState.unlock_world("waterfall")
	GameState.mark_map_clue_seen()


func _prepare_waterfall_gameplay() -> void:
	SceneRouter.pending_payload.clear()
	GameState.begin_new_game()
	GameState.mark_intro_seen()
	GameState.unlock_world("waterfall")
	GameState.mark_map_clue_seen()
	GameState.mark_waterfall_intro_seen()


func _prepare_reward_scene() -> void:
	SceneRouter.pending_payload = {"world_id": "waterfall"}
	GameState.begin_new_game()
	GameState.mark_intro_seen()
	GameState.unlock_world("waterfall")
	GameState.mark_map_clue_seen()
	GameState.mark_waterfall_intro_seen()
	GameState.add_heart_stars(4)
	for task_id in CORE_TASK_IDS:
		GameState.mark_task_complete("waterfall", task_id, 0)
	GameState.complete_world("waterfall")


func _prepare_map_room_restored() -> void:
	SceneRouter.pending_payload.clear()
	GameState.begin_new_game()
	GameState.mark_intro_seen()
	GameState.unlock_world("waterfall")
	GameState.mark_map_clue_seen()
	GameState.mark_waterfall_intro_seen()
	GameState.add_heart_stars(4)
	for task_id in CORE_TASK_IDS:
		GameState.mark_task_complete("waterfall", task_id, 0)
	GameState.complete_world("waterfall")


func _prepare_forest_gameplay() -> void:
	SceneRouter.pending_payload = {"world_id": "forest"}
	GameState.begin_new_game()
	GameState.mark_intro_seen()
	GameState.mark_map_clue_seen()
	GameState.mark_world_intro_seen("waterfall")
	for task_id in CORE_TASK_IDS:
		GameState.mark_task_complete("waterfall", task_id, 0)
	GameState.complete_world("waterfall")
	GameState.mark_world_intro_seen("forest")


func _prepare_beach_gameplay() -> void:
	_prepare_forest_gameplay()
	SceneRouter.pending_payload = {"world_id": "beach"}
	for task_id in ["forest_colors", "forest_shapes", "forest_sort", "forest_letters"]:
		GameState.mark_task_complete("forest", task_id, 0)
	GameState.complete_world("forest")
	GameState.mark_world_intro_seen("beach")


func _prepare_zoo_gameplay() -> void:
	_prepare_beach_gameplay()
	SceneRouter.pending_payload = {"world_id": "zoo"}
	for task_id in ["beach_count", "beach_pattern", "beach_sizes", "beach_match"]:
		GameState.mark_task_complete("beach", task_id, 0)
	GameState.complete_world("beach")
	GameState.mark_world_intro_seen("zoo")


func _prepare_house_gameplay() -> void:
	_prepare_zoo_gameplay()
	SceneRouter.pending_payload = {"world_id": "house"}
	for task_id in ["zoo_sounds", "zoo_memory", "zoo_count", "zoo_phonics"]:
		GameState.mark_task_complete("zoo", task_id, 0)
	GameState.complete_world("zoo")
	GameState.mark_world_intro_seen("house")


func _stage_castle_intro_ready(scene_instance: Node) -> void:
	var dialogue_bubble := scene_instance.get_node_or_null("CanvasLayer/DialogueBubble")
	if dialogue_bubble != null:
		dialogue_bubble.hide()
		dialogue_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if scene_instance.has_method("_on_dialogue_finished"):
		scene_instance.call("_on_dialogue_finished")
