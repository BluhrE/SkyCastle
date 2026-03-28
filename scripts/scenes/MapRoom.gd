extends Node2D

const UNLOCKED_MARKER_TEXTURE := preload("res://assets/art/first_slice/props/map_room/prop_map_room_marker_waterfall.svg")
const LOCKED_MARKER_TEXTURE := preload("res://assets/art/first_slice/props/map_room/prop_map_room_marker_locked.svg")

@onready var dialogue = $CanvasLayer/DialogueBubble
@onready var hint_panel = $CanvasLayer/HintPanel
@onready var star_label = $CanvasLayer/HudRibbon/MarginContainer/HBoxContainer/StarCount
@onready var ribbon_label = $CanvasLayer/HudRibbon/MarginContainer/HBoxContainer/RibbonCount
@onready var waterfall_button = $PlayLayer/WaterfallMarker
@onready var forest_marker = $PlayLayer/ForestMarker
@onready var beach_marker = $PlayLayer/BeachMarker
@onready var zoo_marker = $PlayLayer/ZooMarker
@onready var house_marker = $PlayLayer/HouseMarker
@onready var waterfall_path = $Midground/WaterfallPath
@onready var forest_path = $Midground/ForestPath
@onready var beach_path = $Midground/BeachPath
@onready var zoo_path = $Midground/ZooPath
@onready var house_path = $Midground/HousePath
@onready var pause_overlay = $CanvasLayer/PauseOverlay
@onready var pause_menu = $CanvasLayer/PauseOverlay/PauseMenu

var dialogue_mode := ""


func _ready() -> void:
	dialogue.dialogue_finished.connect(_on_dialogue_finished)
	GameState.progress_changed.connect(_refresh_state)
	pause_menu.resume_pressed.connect(_on_pause_resume_pressed)
	pause_menu.main_menu_pressed.connect(_on_pause_main_menu_pressed)
	pause_menu.quit_pressed.connect(_on_pause_quit_pressed)
	pause_menu.configure({
		"title": "Map Menu",
		"show_resume": true,
		"resume_text": "Back to Map",
		"show_return_to_map": false,
		"show_main_menu": true,
		"show_quit": true
	})
	pause_overlay.visible = false
	_load_world_path_art()
	_refresh_state()
	var payload := SceneRouter.take_payload()
	if payload.get("dialogue", "") != "":
		dialogue_mode = String(payload.get("dialogue"))
		dialogue.show_lines(DialogueLibrary.get_lines(dialogue_mode))
	elif not GameState.save_data.get("map_clue_seen", false):
		dialogue_mode = "map_first_visit"
		GameState.mark_map_clue_seen()
		dialogue.show_lines(DialogueLibrary.get_lines(dialogue_mode))
	else:
		hint_panel.set_hint(HintManager.get_hint("map_room"))


func _exit_tree() -> void:
	if GameState.progress_changed.is_connected(_refresh_state):
		GameState.progress_changed.disconnect(_refresh_state)


func _refresh_state() -> void:
	star_label.text = "Heart Stars: %d" % GameState.get_heart_stars()
	ribbon_label.text = "Sunset Ribbons: %d" % GameState.get_ribbon_total()
	var waterfall_unlocked := GameState.is_world_unlocked("waterfall")
	var waterfall_done := GameState.is_world_completed("waterfall")
	waterfall_button.disabled = not waterfall_unlocked
	waterfall_button.text = "Glitterdrop\nWaterfall" if not waterfall_done else "Glitterdrop\nRestored!"
	waterfall_button.modulate = Color(1.0, 1.0, 1.0) if waterfall_unlocked else Color(0.65, 0.65, 0.65)
	waterfall_path.modulate = Color(0.98, 0.78, 0.42) if waterfall_done else Color(0.93, 0.63, 0.81)
	_update_marker_state("forest", forest_marker)
	_update_marker_state("beach", beach_marker)
	_update_marker_state("zoo", zoo_marker)
	_update_marker_state("house", house_marker)
	_update_path_state("forest", forest_path)
	_update_path_state("beach", beach_path)
	_update_path_state("zoo", zoo_path)
	_update_path_state("house", house_path)
	hint_panel.set_hint(HintManager.get_hint("map_room"))


func _on_dialogue_finished() -> void:
	dialogue_mode = ""
	hint_panel.set_hint(HintManager.get_hint("map_room"))


func _on_waterfall_marker_pressed() -> void:
	var world: Dictionary = WorldLibrary.get_world("waterfall")
	SceneRouter.go_to(String(world.get("scene", "res://scenes/worlds/WaterfallWorld.tscn")), {"world_id": "waterfall"})


func _update_marker_state(world_id: String, button: Button) -> void:
	var world: Dictionary = WorldLibrary.get_world(world_id)
	var world_name := String(world.get("name", world_id.capitalize()))
	var unlocked := GameState.is_world_unlocked(world_id)
	var completed := GameState.is_world_completed(world_id)
	var marker_art: TextureRect = button.get_node("MarkerArt")
	button.disabled = not unlocked
	button.modulate = Color(1.0, 1.0, 1.0) if unlocked else Color(0.72, 0.72, 0.72)
	marker_art.texture = UNLOCKED_MARKER_TEXTURE if unlocked else LOCKED_MARKER_TEXTURE
	marker_art.modulate = _marker_color(world_id, completed)
	if completed:
		button.text = "%s\nRestored!" % _short_world_name(world_name)
	elif unlocked:
		button.text = _short_world_name(world_name)
	else:
		button.text = "%s\nLocked" % _short_world_name(world_name)


func _load_world_path_art() -> void:
	var path_nodes := {
		"forest": forest_path,
		"beach": beach_path,
		"zoo": zoo_path,
		"house": house_path
	}
	for world_id in path_nodes.keys():
		var world: Dictionary = WorldLibrary.get_world(world_id)
		var path_node: TextureRect = path_nodes[world_id]
		var path_texture := String(world.get("path_texture", ""))
		if not path_texture.is_empty():
			path_node.texture = load(path_texture)


func _update_path_state(world_id: String, path_node: TextureRect) -> void:
	var unlocked := GameState.is_world_unlocked(world_id)
	var completed := GameState.is_world_completed(world_id)
	path_node.visible = unlocked or completed
	path_node.modulate = _marker_color(world_id, completed)


func _marker_color(world_id: String, completed: bool) -> Color:
	var colors := {
		"forest": Color(0.63, 0.84, 0.54, 1.0),
		"beach": Color(0.47, 0.82, 0.94, 1.0),
		"zoo": Color(0.62, 0.82, 0.56, 1.0),
		"house": Color(0.96, 0.73, 0.56, 1.0)
	}
	var base: Color = colors.get(world_id, Color.WHITE)
	return base.lightened(0.18) if completed else base


func _short_world_name(world_name: String) -> String:
	return world_name.replace(" of ", "\n").replace(" with ", "\n")


func _travel_to_world(world_id: String) -> void:
	var world: Dictionary = WorldLibrary.get_world(world_id)
	SceneRouter.go_to(String(world.get("scene", "")), {"world_id": world_id})


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if dialogue.visible:
			get_viewport().set_input_as_handled()
			return
		pause_overlay.visible = not pause_overlay.visible
		get_viewport().set_input_as_handled()


func _on_forest_marker_pressed() -> void:
	_travel_to_world("forest")


func _on_beach_marker_pressed() -> void:
	_travel_to_world("beach")


func _on_zoo_marker_pressed() -> void:
	_travel_to_world("zoo")


func _on_house_marker_pressed() -> void:
	_travel_to_world("house")


func _on_pause_resume_pressed() -> void:
	pause_overlay.visible = false


func _on_pause_main_menu_pressed() -> void:
	SceneRouter.go_to_main_menu()


func _on_pause_quit_pressed() -> void:
	get_tree().quit()
