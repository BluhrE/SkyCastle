extends Node

signal world_started(world_id)
signal task_completed(world_id, task_id)
signal core_tasks_ready(world_id)
signal world_completed(world_id)

var active_world_id := ""
var tasks: Array = []
var task_lookup: Dictionary = {}


func start_world(world_id: String) -> void:
	active_world_id = world_id
	tasks.clear()
	task_lookup.clear()
	var world: Dictionary = WorldLibrary.get_world(world_id)
	var task_file := String(world.get("task_file", ""))
	if not task_file.is_empty():
		var file := FileAccess.open(task_file, FileAccess.READ)
		if file:
			var parsed = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				tasks = parsed.get("tasks", []).duplicate(true)
				for task in tasks:
					var task_dict: Dictionary = task
					task_lookup[String(task_dict.get("id", ""))] = task_dict
	print("[Quest] Started world: ", world_id)
	emit_signal("world_started", world_id)


func get_tasks(include_final: bool = true) -> Array:
	if include_final:
		return tasks.duplicate(true)
	var filtered: Array = []
	for task in tasks:
		var task_dict: Dictionary = task
		if String(task_dict.get("type", "")) != "final":
			filtered.append(task_dict)
	return filtered


func get_task(task_id: String) -> Dictionary:
	return task_lookup.get(task_id, {})


func get_first_incomplete_task_name() -> String:
	for task in get_tasks(false):
		var task_dict: Dictionary = task
		var task_id := String(task_dict.get("id", ""))
		if not GameState.has_completed_task(active_world_id, task_id):
			return String(task_dict.get("name", ""))
	return ""


func are_core_tasks_complete() -> bool:
	for task in get_tasks(false):
		var task_dict: Dictionary = task
		if not GameState.has_completed_task(active_world_id, String(task_dict.get("id", ""))):
			return false
	return true


func complete_task(task_id: String) -> bool:
	if active_world_id.is_empty():
		return false
	if GameState.has_completed_task(active_world_id, task_id):
		return false
	var task: Dictionary = get_task(task_id)
	if task.is_empty():
		return false
	print("[Quest] Completing task request: ", active_world_id, "/", task_id)
	GameState.mark_task_complete(active_world_id, task_id, int(task.get("stars", 0)))
	emit_signal("task_completed", active_world_id, task_id)
	if String(task.get("type", "")) == "final":
		GameState.complete_world(active_world_id)
		emit_signal("world_completed", active_world_id)
	elif are_core_tasks_complete():
		print("[Quest] Core tasks ready for world: ", active_world_id)
		emit_signal("core_tasks_ready", active_world_id)
	return true
