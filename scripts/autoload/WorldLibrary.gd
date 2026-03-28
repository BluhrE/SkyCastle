extends Node

const WORLD_DATA_PATH := "res://data/worlds/worlds.json"

var worlds_by_id: Dictionary = {}
var ordered_worlds: Array = []


func _ready() -> void:
	_load_worlds()


func _load_worlds() -> void:
	worlds_by_id.clear()
	ordered_worlds.clear()
	var file := FileAccess.open(WORLD_DATA_PATH, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return
	for world in parsed.get("worlds", []):
		var world_dict: Dictionary = world
		var world_id := String(world_dict.get("id", ""))
		if world_id.is_empty():
			continue
		ordered_worlds.append(world_dict)
		worlds_by_id[world_id] = world_dict


func get_world(world_id: String) -> Dictionary:
	return worlds_by_id.get(world_id, {})


func get_worlds() -> Array:
	return ordered_worlds.duplicate(true)


func get_world_ids() -> Array:
	var ids: Array = []
	for world in ordered_worlds:
		var world_dict: Dictionary = world
		ids.append(String(world_dict.get("id", "")))
	return ids


func get_next_world_id(world_id: String) -> String:
	var ids := get_world_ids()
	var index := ids.find(world_id)
	if index == -1 or index >= ids.size() - 1:
		return ""
	return String(ids[index + 1])


func get_previous_world_id(world_id: String) -> String:
	var ids := get_world_ids()
	var index := ids.find(world_id)
	if index <= 0:
		return ""
	return String(ids[index - 1])
