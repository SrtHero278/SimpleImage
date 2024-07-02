extends Label

@onready var spin_box = $SpinBox
@onready var slider = $HSlider

signal on_change(value:float)

func _change(value):
	spin_box.set_value_no_signal(value)
	slider.set_value_no_signal(value)
	on_change.emit(value)
