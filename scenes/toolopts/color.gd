extends Label

@onready var button = $Button

signal on_change(val:Color)

func _change(val:Color):
	button.color = val
	on_change.emit(val)

func _popup_closed():
	Main.scene.stop_input = false
func _pressed():
	Main.scene.stop_input = true
