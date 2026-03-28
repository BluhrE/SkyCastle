extends CanvasLayer

var pending_payload: Dictionary = {}
var overlay: ColorRect


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay = ColorRect.new()
	overlay.color = Color(0.24, 0.13, 0.22, 0.0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)


func go_to(scene_path: String, payload: Dictionary = {}, use_fade: bool = true) -> void:
	pending_payload = payload.duplicate(true)
	print("[Scene] Transitioning to ", scene_path)
	if use_fade:
		await _fade_to(1.0)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	if use_fade:
		await _fade_to(0.0)


func go_to_main_menu() -> void:
	go_to("res://scenes/menu/MainMenu.tscn", {})


func take_payload() -> Dictionary:
	var payload := pending_payload.duplicate(true)
	pending_payload.clear()
	return payload


func _fade_to(target_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", target_alpha, 0.35)
	await tween.finished
