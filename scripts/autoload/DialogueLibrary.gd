extends Node

const DIALOGUE_PATH := "res://dialogue/dialogue_lines.json"

var dialogue_data: Dictionary = {}


func _ready() -> void:
	_load_dialogue()


func _load_dialogue() -> void:
	var file := FileAccess.open(DIALOGUE_PATH, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		dialogue_data = parsed


func get_lines(dialogue_id: String) -> Array:
	return dialogue_data.get(dialogue_id, []).duplicate(true)

