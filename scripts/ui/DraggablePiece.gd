extends TextureRect

signal piece_released(piece)

var home_position := Vector2.ZERO
var dragging := false
var drag_offset := Vector2.ZERO


func _ready() -> void:
	home_position = position
	mouse_filter = Control.MOUSE_FILTER_STOP
	if texture == null:
		var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		texture = ImageTexture.create_from_image(image)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = get_local_mouse_position()
			scale = Vector2(1.08, 1.08)
			move_to_front()
		elif dragging:
			dragging = false
			scale = Vector2.ONE
			emit_signal("piece_released", self)
	elif event is InputEventMouseMotion and dragging:
		global_position = event.global_position - drag_offset


func reset_to_home() -> void:
	position = home_position
	scale = Vector2.ONE
