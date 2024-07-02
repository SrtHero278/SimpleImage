class_name Pencil extends BasePainter

var color:Color = Color.BLACK

func _init():
	name = "Pencil"
	icon = load("res://assets/icons/pencil.png")

func apply_draw(pos):
	Main.scene.cur_layer_img.fill_rect(Rect2i(pos - Main.scene.layers.position - (internal_size * 0.5), internal_size), color)

func make_opts(parent):
	super.make_opts(parent)
	var color_obj = load("res://scenes/toolopts/color.tscn")
	var color_inst = color_obj.instantiate()
	parent.add_child(color_inst)
	color_inst._change(color)
	color_inst.on_change.connect(func(val): color = val)
