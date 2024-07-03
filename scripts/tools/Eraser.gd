class_name Eraser extends BasePainter

const TRANSPARENT = Color(0.0, 0.0, 0.0, 0.0) # Color.TRANSPARENT has an rgb of white, causing a weird halo.

func _init():
	name = "Eraser"
	icon = load("res://assets/icons/eraser.png")

func apply_draw(pos):
	Main.scene.cur_layer_img.fill_rect(Rect2i(pos - (internal_size * 0.5), internal_size), TRANSPARENT)
