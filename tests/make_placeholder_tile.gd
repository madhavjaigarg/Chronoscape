@tool
extends EditorScript

func _run() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.35, 0.35, 0.4))
	for i in 32:
		img.set_pixel(i, 0, Color(0.6, 0.6, 0.7))
		img.set_pixel(0, i, Color(0.6, 0.6, 0.7))
	img.save_png("res://art/tiles/placeholder_ground.png")
