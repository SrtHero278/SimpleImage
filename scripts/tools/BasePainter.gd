class_name BasePainter extends Tool

var size:int = 8:
	set(val):
		set_size(val)
		size = val
var internal_size:Vector2i = Vector2i(size, size)
var in_use:bool = false

func input(event):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if not event.pressed or event.position < Main.scene.layers.position or event.position > Main.scene.layers.position + Main.scene.layers.size:
					in_use = false
					return
				in_use = true
				apply_draw(event.position)
				Main.scene.cur_layer_tex.update(Main.scene.cur_layer_img)
	if event is InputEventMouseMotion and in_use:
		event = event as InputEventMouseMotion
		event.position = event.position.round()
		event.relative = event.relative.round()
		var cur_pos = event.position - event.relative
		draw_to(cur_pos, event.position, event.relative)

func cancel_input():
	in_use = false

func make_opts(parent):
	var slider = load("res://scenes/toolopts/slider.tscn")
	var size_box = slider.instantiate()
	parent.add_child(size_box)
	size_box.on_change.connect(func(val): size = floori(val))
	size_box._change(size)

func draw_to(start_pos:Vector2, end_pos:Vector2, relative = null):
	if relative == null:
		relative = start_pos - end_pos
	var inc = relative / maxf(absf(relative.x), absf(relative.y))
	while start_pos.round() != end_pos:
		start_pos += inc
		apply_draw(start_pos)
	Main.scene.cur_layer_tex.update(Main.scene.cur_layer_img)

func apply_draw(_pos):
	pass

func set_size(val:int):
	internal_size.x = val
	internal_size.y = val
