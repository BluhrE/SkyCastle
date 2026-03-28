extends Node2D

enum ConfirmAction {
	NONE,
	NEW_GAME,
	RESET_PROGRESS,
	QUIT_GAME
}

@onready var continue_button = $CanvasLayer/MenuPanel/MarginContainer/VBoxContainer/ContinueButton
@onready var new_game_button = $CanvasLayer/MenuPanel/MarginContainer/VBoxContainer/NewGameButton
@onready var reset_button = $CanvasLayer/MenuPanel/MarginContainer/VBoxContainer/ResetButton
@onready var quit_button = $CanvasLayer/MenuPanel/MarginContainer/VBoxContainer/QuitButton
@onready var confirm_overlay = $CanvasLayer/ConfirmOverlay
@onready var confirm_panel = $CanvasLayer/ConfirmOverlay/ConfirmPanel
@onready var confirm_label = $CanvasLayer/ConfirmOverlay/ConfirmPanel/MarginContainer/VBoxContainer/ConfirmLabel

var pending_action := ConfirmAction.NONE


func _ready() -> void:
	GameState.initialize()
	_refresh_buttons()
	_hide_confirm()


func _refresh_buttons() -> void:
	var has_save := GameState.has_save_file()
	continue_button.visible = has_save
	reset_button.visible = has_save
	new_game_button.text = "New Game" if not has_save else "New Game (Overwrite)"


func _show_confirm(message: String, action: int) -> void:
	pending_action = action
	confirm_label.text = message
	confirm_overlay.visible = true


func _hide_confirm() -> void:
	pending_action = ConfirmAction.NONE
	confirm_overlay.visible = false


func _start_new_game() -> void:
	GameState.begin_new_game()
	SceneRouter.go_to("res://scenes/castle/CastleIntro.tscn", {"new_game": true})


func _continue_game() -> void:
	GameState.load_save()
	SceneRouter.go_to(GameState.get_resume_scene_path(), {})


func _reset_progress() -> void:
	GameState.reset_progress(true)
	_refresh_buttons()


func _on_continue_button_pressed() -> void:
	_continue_game()


func _on_new_game_button_pressed() -> void:
	if GameState.has_save_file():
		_show_confirm("Start a fresh adventure? This will replace your current progress.", ConfirmAction.NEW_GAME)
		return
	_start_new_game()


func _on_reset_button_pressed() -> void:
	_show_confirm("Reset all saved progress? This cannot be undone.", ConfirmAction.RESET_PROGRESS)


func _on_quit_button_pressed() -> void:
	_show_confirm("Quit Sky and the Sparkle Crown?", ConfirmAction.QUIT_GAME)


func _on_confirm_yes_button_pressed() -> void:
	match pending_action:
		ConfirmAction.NEW_GAME:
			_start_new_game()
		ConfirmAction.RESET_PROGRESS:
			_reset_progress()
		ConfirmAction.QUIT_GAME:
			get_tree().quit()
	_hide_confirm()


func _on_confirm_no_button_pressed() -> void:
	_hide_confirm()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if confirm_overlay.visible:
			_hide_confirm()
		else:
			_show_confirm("Quit Sky and the Sparkle Crown?", ConfirmAction.QUIT_GAME)
		get_viewport().set_input_as_handled()
