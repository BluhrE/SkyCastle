extends Node


func _ready() -> void:
	call_deferred("_route_into_game")


func _route_into_game() -> void:
	GameState.initialize()
	if OS.get_cmdline_user_args().has("--capture-screenshots"):
		await SceneRouter.go_to("res://scenes/dev/ScreenshotCapture.tscn", {}, false)
		return
	await SceneRouter.go_to("res://scenes/menu/MainMenu.tscn", {}, false)
