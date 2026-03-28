extends Node

signal progress_changed
signal reward_earned(kind, amount)

const SAVE_PATH := "user://sky_save.json"

var save_data: Dictionary = {}


func _ready() -> void:
	initialize()


func initialize() -> void:
	if save_data.is_empty():
		load_save()


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func _default_world_state(is_unlocked: bool = false) -> Dictionary:
	return {
		"unlocked": is_unlocked,
		"completed": false,
		"ribbon_earned": false,
		"tasks_completed": [],
		"intro_seen": false,
		"reward_seen": false,
		"visited_count": 0,
		"collectibles": [],
		"bonus_flags": {},
		"friend_request_open": false,
		"revisit_unlocked": true
	}


func _default_save() -> Dictionary:
	return {
		"intro_seen": false,
		"map_clue_seen": false,
		"waterfall_intro_seen": false,
		"waterfall_reward_seen": false,
		"waterfall_unlocked": false,
		"waterfall_completed": false,
		"heart_stars": 0,
		"first_sunset_ribbon": false,
		"sunset_ribbons": [],
		"current_map_unlock_state": "castle",
		"celebration_ready": false,
		"castle_rewards": [],
		"worlds": {
			"waterfall": _default_world_state(false),
			"forest": _default_world_state(false),
			"beach": _default_world_state(false),
			"zoo": _default_world_state(false),
			"house": _default_world_state(false)
		}
	}


func _merge_with_defaults(source: Dictionary) -> Dictionary:
	var merged := _default_save()
	for key in source.keys():
		if key == "worlds" and source[key] is Dictionary:
			for world_id in source[key].keys():
				merged["worlds"][world_id] = _default_world_state(false)
				var incoming_world: Dictionary = source[key][world_id]
				for world_key in incoming_world.keys():
					merged["worlds"][world_id][world_key] = incoming_world[world_key]
		else:
			merged[key] = source[key]
	_sync_flags(merged)
	return merged


func _sync_flags(data: Dictionary = save_data) -> void:
	var waterfall: Dictionary = data["worlds"].get("waterfall", _default_world_state(false))
	data["waterfall_unlocked"] = waterfall.get("unlocked", false)
	data["waterfall_completed"] = waterfall.get("completed", false)
	data["first_sunset_ribbon"] = waterfall.get("ribbon_earned", false)
	data["waterfall_intro_seen"] = waterfall.get("intro_seen", false)
	data["waterfall_reward_seen"] = waterfall.get("reward_seen", false)


func load_save() -> void:
	save_data = _default_save()
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var parsed = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				save_data = _merge_with_defaults(parsed)
				print("[Save] Loaded save data from ", SAVE_PATH)
	else:
		print("[Save] No save file found. Using default progress.")
	_sync_flags()
	emit_signal("progress_changed")


func save_game() -> void:
	_sync_flags()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		print("[Save] Saved progress to ", SAVE_PATH)


func begin_new_game() -> void:
	save_data = _default_save()
	save_data["worlds"]["waterfall"]["unlocked"] = true
	_sync_flags()
	save_game()
	emit_signal("progress_changed")
	print("[Save] Began a new game.")


func reset_progress(delete_save_file: bool = true) -> void:
	save_data = _default_save()
	_sync_flags()
	if delete_save_file and has_save_file():
		var absolute_path := ProjectSettings.globalize_path(SAVE_PATH)
		var result := DirAccess.remove_absolute(absolute_path)
		print("[Save] Reset progress. Remove result: ", result)
	else:
		print("[Save] Reset progress in memory.")
	emit_signal("progress_changed")


func get_resume_scene_path() -> String:
	if not save_data.get("intro_seen", false):
		return "res://scenes/castle/CastleIntro.tscn"
	return "res://scenes/map/MapRoom.tscn"


func ensure_world(world_id: String) -> void:
	if not save_data["worlds"].has(world_id):
		save_data["worlds"][world_id] = _default_world_state(false)


func mark_intro_seen() -> void:
	save_data["intro_seen"] = true
	save_data["current_map_unlock_state"] = "map_room"
	save_game()
	emit_signal("progress_changed")


func mark_map_clue_seen() -> void:
	save_data["map_clue_seen"] = true
	save_game()
	emit_signal("progress_changed")


func mark_waterfall_intro_seen() -> void:
	mark_world_intro_seen("waterfall")


func mark_waterfall_reward_seen() -> void:
	mark_world_reward_seen("waterfall")


func unlock_world(world_id: String) -> void:
	ensure_world(world_id)
	save_data["worlds"][world_id]["unlocked"] = true
	save_data["current_map_unlock_state"] = world_id
	save_game()
	emit_signal("progress_changed")


func is_world_unlocked(world_id: String) -> bool:
	ensure_world(world_id)
	return save_data["worlds"][world_id].get("unlocked", false)


func is_world_completed(world_id: String) -> bool:
	ensure_world(world_id)
	return save_data["worlds"][world_id].get("completed", false)


func has_ribbon(world_id: String) -> bool:
	ensure_world(world_id)
	return save_data["worlds"][world_id].get("ribbon_earned", false)


func has_seen_world_intro(world_id: String) -> bool:
	ensure_world(world_id)
	return save_data["worlds"][world_id].get("intro_seen", false)


func mark_world_intro_seen(world_id: String) -> void:
	ensure_world(world_id)
	save_data["worlds"][world_id]["intro_seen"] = true
	if world_id == "waterfall":
		save_data["waterfall_intro_seen"] = true
	save_game()
	emit_signal("progress_changed")


func has_seen_world_reward(world_id: String) -> bool:
	ensure_world(world_id)
	return save_data["worlds"][world_id].get("reward_seen", false)


func mark_world_reward_seen(world_id: String) -> void:
	ensure_world(world_id)
	save_data["worlds"][world_id]["reward_seen"] = true
	if world_id == "waterfall":
		save_data["waterfall_reward_seen"] = true
	save_game()
	emit_signal("progress_changed")


func mark_world_visited(world_id: String) -> void:
	ensure_world(world_id)
	save_data["worlds"][world_id]["visited_count"] = int(save_data["worlds"][world_id].get("visited_count", 0)) + 1
	save_game()
	emit_signal("progress_changed")


func get_completed_tasks(world_id: String) -> Array:
	ensure_world(world_id)
	return save_data["worlds"][world_id].get("tasks_completed", []).duplicate()


func has_completed_task(world_id: String, task_id: String) -> bool:
	return get_completed_tasks(world_id).has(task_id)


func mark_task_complete(world_id: String, task_id: String, star_reward: int = 0) -> void:
	ensure_world(world_id)
	var completed: Array = save_data["worlds"][world_id].get("tasks_completed", [])
	if completed.has(task_id):
		return
	completed.append(task_id)
	save_data["worlds"][world_id]["tasks_completed"] = completed
	print("[Quest] Marked task complete: ", world_id, "/", task_id)
	if star_reward > 0:
		add_heart_stars(star_reward)
	save_game()
	emit_signal("progress_changed")


func add_heart_stars(amount: int) -> void:
	if amount <= 0:
		return
	save_data["heart_stars"] += amount
	print("[Reward] Added Heart Stars: +", amount, " (total ", save_data["heart_stars"], ")")
	save_game()
	emit_signal("reward_earned", "heart_stars", amount)
	emit_signal("progress_changed")


func grant_ribbon(world_id: String) -> void:
	ensure_world(world_id)
	if save_data["worlds"][world_id].get("ribbon_earned", false):
		return
	save_data["worlds"][world_id]["ribbon_earned"] = true
	var ribbons: Array = save_data.get("sunset_ribbons", [])
	if not ribbons.has(world_id):
		ribbons.append(world_id)
	save_data["sunset_ribbons"] = ribbons
	print("[Reward] Granted Sunset Ribbon for ", world_id)
	save_game()
	emit_signal("reward_earned", "sunset_ribbon", 1)
	emit_signal("progress_changed")


func complete_world(world_id: String) -> void:
	ensure_world(world_id)
	save_data["worlds"][world_id]["completed"] = true
	grant_ribbon(world_id)
	save_data["current_map_unlock_state"] = "%s_restored" % world_id
	var next_world_id := WorldLibrary.get_next_world_id(world_id)
	if not next_world_id.is_empty():
		unlock_world(next_world_id)
	else:
		save_data["celebration_ready"] = true
	print("[Quest] Completed world: ", world_id)
	save_game()
	emit_signal("progress_changed")


func get_heart_stars() -> int:
	return int(save_data.get("heart_stars", 0))


func get_ribbon_total() -> int:
	return int(save_data.get("sunset_ribbons", []).size())


func get_collectibles(world_id: String) -> Array:
	ensure_world(world_id)
	return save_data["worlds"][world_id].get("collectibles", []).duplicate()


func has_collectible(world_id: String, collectible_id: String) -> bool:
	return get_collectibles(world_id).has(collectible_id)


func add_collectible(world_id: String, collectible_id: String) -> void:
	ensure_world(world_id)
	var collectibles: Array = save_data["worlds"][world_id].get("collectibles", [])
	if collectibles.has(collectible_id):
		return
	collectibles.append(collectible_id)
	save_data["worlds"][world_id]["collectibles"] = collectibles
	save_game()
	emit_signal("progress_changed")
