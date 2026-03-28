extends SceneTree


func _initialize() -> void:
	var voice_path := "res://audio/voices/sky/voice_sky_intro_test.mp3"
	var resource := load(voice_path)
	if resource == null:
		push_error("Audio load failed: %s" % voice_path)
		quit(1)
		return
	print("Audio load ok: ", voice_path, " -> ", resource.get_class())
	quit()
