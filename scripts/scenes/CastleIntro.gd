extends Node2D

@onready var dialogue = $CanvasLayer/DialogueBubble
@onready var hint_panel = $CanvasLayer/HintPanel
@onready var enter_button = $PlayLayer/MapDoorButton
@onready var collar_glow = $PlayLayer/SkyCollarGlow
@onready var pause_overlay = $CanvasLayer/PauseOverlay
@onready var pause_menu = $CanvasLayer/PauseOverlay/PauseMenu


func _ready() -> void:
	enter_button.visible = false
	enter_button.disabled = true
	hint_panel.set_hint(HintManager.get_hint("castle_intro"))
	dialogue.dialogue_finished.connect(_on_dialogue_finished)
	pause_menu.resume_pressed.connect(_on_pause_resume_pressed)
	pause_menu.main_menu_pressed.connect(_on_pause_main_menu_pressed)
	pause_menu.quit_pressed.connect(_on_pause_quit_pressed)
	pause_menu.configure({
		"title": "Story Menu",
		"show_resume": true,
		"resume_text": "Back to Story",
		"show_return_to_map": false,
		"show_main_menu": true,
		"show_quit": true
	})
	pause_overlay.visible = false
	dialogue.show_lines(DialogueLibrary.get_lines("castle_intro"))
	_start_glow_loop()


func _start_glow_loop() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(collar_glow, "scale", Vector2(1.15, 1.15), 0.9)
	tween.tween_property(collar_glow, "modulate:a", 0.55, 0.9)
	tween.tween_property(collar_glow, "scale", Vector2.ONE, 0.9)
	tween.tween_property(collar_glow, "modulate:a", 1.0, 0.9)


func _on_dialogue_finished() -> void:
	GameState.mark_intro_seen()
	GameState.unlock_world("waterfall")
	enter_button.visible = true
	enter_button.disabled = false
	hint_panel.set_hint("Click the glowing tower door to visit the Rainbow Adventure Map.")


func _on_map_door_button_pressed() -> void:
	SceneRouter.go_to("res://scenes/map/MapRoom.tscn", {"from_scene": "castle_intro"})


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if dialogue.visible:
			get_viewport().set_input_as_handled()
			return
		pause_overlay.visible = not pause_overlay.visible
		get_viewport().set_input_as_handled()


func _on_pause_resume_pressed() -> void:
	pause_overlay.visible = false


func _on_pause_main_menu_pressed() -> void:
	SceneRouter.go_to_main_menu()


func _on_pause_quit_pressed() -> void:
	get_tree().quit()
