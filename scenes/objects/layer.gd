class_name Layer extends Button

@onready var delete:TextureButton = $Delete
@onready var edit:TextureButton = $Edit
@onready var image:TextureRect = $Image
@onready var label:Label = $Label

static func create(img:Texture2D, parent:Control):
	var button:Layer = load("res://scenes/objects/layer.tscn").instantiate()
	parent.insert(button)
	button.image.texture = img
	var img_size = img.get_size()
	button.image.size = Vector2(31.0 * (img_size.x / img_size.y), 31.0)
	button.label.position.x = button.image.size.x + 5
	return button
