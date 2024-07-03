class_name Main extends Control

static var scene:Main
static var load_path:String = "<NEW>"

static func invert_index(index:int):
	return Main.scene.layer_lock.size() - 1 - index

@onready var layers = $BG
@onready var layer_edit = $LayerEdit
@onready var layer_name = $LayerEdit/Name
@onready var layer_vis = $LayerEdit/Visible
@onready var layer_check = $LayerEdit/CanDraw
@onready var layer_alpha = $LayerEdit/Slider
@onready var tool_panel = $ToolPanel
@onready var project_dialog = $SelectProject
var layer_lock:Array[bool] = []
var cur_layer_index:int = 0
var cur_layer_tex:ImageTexture
var cur_layer_img:Image
var stop_input:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Main.scene = self
	if load_path == "<NEW>":
		tool_panel.add_layer()
	else:
		if not FileAccess.file_exists("res://data.json"):
			OS.alert("We were unable to find \"data.json\" in your PCK file.\nAre you sure this is a proper SimpleImage PCK?", "Data not found")
			tool_panel.add_layer()
			return
		
		var data = JSON.parse_string(FileAccess.get_file_as_string("res://data.json"))
		layers.size = Vector2(data.width, data.height)
		for layer in data.layers:
			tool_panel.add_layer()
			cur_layer_img.load_png_from_buffer(FileAccess.get_file_as_bytes(layer.path))
			cur_layer_tex.update(cur_layer_img)
			var layer_spr = layers.get_child(cur_layer_index)
			layer_spr.name = layer.name
			tool_panel.layers.get_child(0).label.text = layer_spr.name
			layer_spr.modulate.a = layer.alpha
func _exit_tree():
	Main.scene = null

func check_panel(panel:Panel, pos:Vector2):
	return panel.visible and panel.get_global_rect().has_point(pos)
func _input(event):
	if stop_input or layer_lock[cur_layer_index]: return
	
	if event.is_action_pressed("save"):
		project_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		project_dialog.popup()
	elif event.is_action_pressed("open"):
		project_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		project_dialog.popup()
	
	if event is InputEventMouse:
		event = event as InputEventMouse
		if check_panel(tool_panel, event.position) or check_panel(layer_edit, event.position):
			tool_panel.cur_tool.cancel_input()
		else:
			tool_panel.cur_tool.input(event)
			if event is InputEventMouseButton:
				event = event as InputEventMouseButton
				match event.button_index:
					MOUSE_BUTTON_WHEEL_UP:
						var og_scale = layers.scale
						var origin = (event.position - layers.position) / (layers.size * og_scale)
						layers.scale += Vector2(0.1, 0.1)
						layers.scale = layers.scale.clamp(Vector2(0.1, 0.1), Vector2(25, 25))
						layers.position -= (layers.size * layers.scale - layers.size * og_scale) * origin
					MOUSE_BUTTON_WHEEL_DOWN:
						var og_scale = layers.scale
						var origin = (event.position - layers.position) / (layers.size * og_scale)
						layers.scale -= Vector2(0.1, 0.1)
						layers.scale = layers.scale.clamp(Vector2(0.1, 0.1), Vector2(25, 25))
						layers.position -= (layers.size * layers.scale - layers.size * og_scale) * origin

func _rename_layer():
	var layer = layers.get_child(cur_layer_index)
	layer.name = layer_name.text
	layer_name.text = layer.name
	tool_panel.layers.get_child(layer_lock.size() - 1 - cur_layer_index).label.text = layer.name
func _layer_name(_unused):
	_rename_layer()
func _layer_alpha(value):
	layers.get_child(cur_layer_index).modulate.a = value * 0.01
func _layer_vis(toggled_on):
	layers.get_child(cur_layer_index).visible = toggled_on
func _layer_lock(toggled_on):
	layer_lock[cur_layer_index] = not toggled_on


func _select_project(path:String):
	if project_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		if not path.ends_with(".pck"):
			path += ".pck"
		DirAccess.make_dir_recursive_absolute("user://TEMP/layers")
		
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
			
		var packer = PCKPacker.new()
		packer.pck_start(path)
		var data = {"width": layers.size.x, "height": layers.size.y, "layers": []}
		
		for i in layers.get_child_count():
			var layer = layers.get_child(i)
			var img:Image = layer.texture.get_image()
			var user_path = "user://TEMP/layers/" + layer.name + ".png"
			var layer_path = "res://layers/" + layer.name + ".png"
			img.save_png(user_path)
			packer.add_file(layer_path, user_path)
			data.layers.append({"name": str(layer.name), "path": layer_path, "visible": layer.visible, "locked": layer_lock[i], "alpha": layer.modulate.a})

		var file = FileAccess.open("user://TEMP/data.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		packer.add_file("res://data.json", "user://TEMP/data.json")
		packer.flush(true)
	else:
		Main.load_path = path.replace("\\", "/")
		ProjectSettings.load_resource_pack(Main.load_path)
		get_tree().change_scene_to_file("res://scenes/main.tscn")
