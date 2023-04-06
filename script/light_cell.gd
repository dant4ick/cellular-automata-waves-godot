extends ColorRect

var height: float = 0.0
var mobility: float = 1.0

var velocity: float = 0.0

@export var exposure: float = 5

var size_setter: Vector2 = Vector2.ONE * 5


func _ready():
	size = size_setter


func colorize():
	color = Color.BLACK + Color.WHITE * abs(height) * exposure + Color.BLUE * (1 - mobility)
