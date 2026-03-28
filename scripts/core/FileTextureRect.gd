extends TextureRect

@export_file("*.png", "*.webp", "*.jpg", "*.jpeg") var source_path := ""


func _ready() -> void:
	if source_path.is_empty():
		return
	var image := Image.load_from_file(source_path)
	if image == null or image.is_empty():
		push_warning("FileTextureRect could not load image: %s" % source_path)
		return
	texture = ImageTexture.create_from_image(image)
