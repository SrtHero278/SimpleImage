extends Container

var min_size:Vector2 = Vector2()
var seperation = 4

var drag_layer:Button = null
var last_pos:Vector2
var mouse_point:Vector2

func _ready():
	get_child(0).size.x = size.x
	min_size.x = size.x

func _process(delta):
	var target_y = 0
	for i in get_child_count():
		var button = get_child(i)
		if button != drag_layer:
			button.position.y = lerpf(button.position.y, target_y, delta * 10)
		target_y += button.size.y + seperation

func _input(event):
	if event is InputEventMouseMotion and drag_layer != null:
		var target_y = clampf(last_pos.y + (event.position.y - mouse_point.y), -5, min_size.y - 60)
		var drag_index = drag_layer.get_index()
		drag_layer.position.y = target_y
		target_y += drag_layer.size.y * 0.5
		for i in get_child_count():
			var button = get_child(i)
			if not button is Layer or button == drag_layer: continue
			var limit_y = button.position.y + button.size.y * 0.5
			if (i > drag_index and target_y > limit_y) or (i < drag_index and target_y < limit_y):
				var index = button.get_index()
				move_child(drag_layer, index)
				Main.scene.layers.move_child(Main.scene.layers.get_child(Main.invert_index(drag_index)), Main.invert_index(index))

func da_sort(a:Button, b:Button):
	return a.position.y + a.size.x * 0.5 > b.position.y + b.size.y * 0.5

func insert(child:Button):
	add_child(child)
	move_child(child, 0)
	child.size.x = size.x
	child.button_down.connect(func():
		drag_layer = child
		last_pos = child.position
		mouse_point = get_global_mouse_position())
	child.button_up.connect(set.bind("drag_layer", null))

func _get_minimum_size():
	min_size.y = 0
	for button in get_children():
		min_size.y += button.size.y + seperation
	min_size.y -= seperation
	return min_size
