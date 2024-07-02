class_name Eraser extends BasePainter

func _init():
	name = "Eraser"
	icon = load("res://assets/icons/eraser.png")

func apply_draw(pos):
	Main.scene.cur_layer_img.fill_rect(Rect2i(pos - Main.scene.layers.position - (internal_size * 0.5), internal_size), Color.TRANSPARENT)
