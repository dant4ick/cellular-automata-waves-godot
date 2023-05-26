extends HSlider

var display_title: Label
var display_value: Label

var DEFAULT_VALUE: float

@export var title: String = "Title"


func _ready():
	DEFAULT_VALUE = value
	
	display_title = find_child("title")
	display_value = find_child("value")
	
	display_title.set_text(title)
	display_value.set_text(str(value))


func _value_changed(new_value: float):
	display_value.set_text(str(new_value))


func _on_restart_pressed():
	value = DEFAULT_VALUE
