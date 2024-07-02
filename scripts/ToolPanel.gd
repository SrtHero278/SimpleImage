class_name ToolPanel extends Panel

var cur_tab = 0

@onready var tool_box := $Tools
@onready var tool_storage := $Tools/Tools
@onready var separator := $Tools/HSeparator
@onready var options := $Tools/Options
var tools:Array[Tool]
var cur_tool:Tool

@onready var layers := $Layers

func _ready():
	tools = [
		Pencil.new(),
		Eraser.new()
	]
	switch_tool(tools[0])
	
	for i in tools.size():
		var tool = tools[i]
		var button = TextureButton.new()
		button.tooltip_text = tool.name
		button.texture_normal = tool.icon
		button.pressed.connect(func(): switch_tool(tool))
		tool_storage.add_child(button)

func _input(event):
	if event.is_pressed() and event is InputEventKey and event.keycode == KEY_TAB:
		if visible:
			get_child(cur_tab).visible = false
		cur_tab = wrapi(cur_tab + 1, 0, get_child_count() + 1)
		visible = cur_tab < get_child_count()
		if visible:
			var tab = get_child(cur_tab)
			tab.visible = true
			tab.size.y = 0
			size.y = tab.size.y + 20
			position.y = get_viewport_rect().size.y - 10 - size.y

func switch_tool(tool:Tool):
	cur_tool = tool
	for old_opt in options.get_children():
		old_opt.queue_free()
	tool.make_opts(options)
	await get_tree().process_frame
	tool_box.size.y = 0
	size.y = tool_box.size.y + 20
	position.y = get_viewport_rect().size.y - 10 - size.y

func switch_layer(button):
	Main.scene.cur_layer_index = Main.invert_index(button.get_index())
	Main.scene.cur_layer_tex = Main.scene.layers.get_child(Main.scene.cur_layer_index).texture
	Main.scene.cur_layer_img = Main.scene.cur_layer_tex.get_image()
func edit_layer(button):
	switch_layer(button)
	Main.scene.layer_edit.visible = true
	var layer = Main.scene.layers.get_child(Main.scene.cur_layer_index)
	Main.scene.layer_name.text = layer.name
	Main.scene.layer_vis.set_pressed_no_signal(layer.visible)
	Main.scene.layer_check.set_pressed_no_signal(not Main.scene.layer_lock[Main.scene.cur_layer_index])
	Main.scene.layer_alpha._change(layer.modulate.a * 100)
func delete_layer(button):
	if Main.scene.layer_lock.size() < 2: return
	
	var cur_button = layers.get_child(layers.get_child_count() - 1 - Main.scene.cur_layer_index)
	var index = Main.invert_index(button.get_index())
	Main.scene.layers.get_child(index).queue_free()
	Main.scene.layer_lock.remove_at(index)
	layers.remove_child(button)
	button.queue_free()
	switch_layer(layers.get_child(0) if cur_button == button else cur_button)
	layers.size.y = 0
	size.y = layers.size.y + 20
	position.y = get_viewport_rect().size.y - 10 - size.y
func add_layer():
	var layer_spr = Sprite2D.new()
	layer_spr.centered = false
	Main.scene.cur_layer_img = Image.create(Main.scene.layers.size.x, Main.scene.layers.size.y, false, Image.FORMAT_RGBA8)
	Main.scene.cur_layer_tex = ImageTexture.create_from_image(Main.scene.cur_layer_img)
	Main.scene.cur_layer_index = Main.scene.layer_lock.size()
	Main.scene.layers.add_child(layer_spr)
	Main.scene.layer_lock.append(false)
	layer_spr.name = "Layer1"
	layer_spr.texture = Main.scene.cur_layer_tex

	var button:Layer = Layer.create(Main.scene.cur_layer_tex, layers)
	button.pressed.connect(switch_layer.bind(button))
	button.edit.pressed.connect(edit_layer.bind(button))
	button.delete.pressed.connect(delete_layer.bind(button))
	button.label.text = layer_spr.name
	layers.size.y = 0
	size.y = get_child(cur_tab).size.y + 20
	position.y = get_viewport_rect().size.y - 10 - size.y
