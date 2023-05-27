extends Node2D

@export var size: int = 10
@export var iterations: int = 10
@export var speed: float = 0.001

var cells: Array = Array()

var viewport_middle: float

var height_multiplier: float

@onready var cell_scene = load("res://scene/wave_cell.tscn")


func _ready():
	var viewport_width = get_viewport_rect().size.x
	var perfect_fit = Vector2.ONE * floor(viewport_width / size)
	viewport_middle = get_viewport_rect().size.y / 2
	for i in size:
		var cell: ColorRect = cell_scene.instantiate()
		cell.size_setter = perfect_fit
		cell.position = Vector2(i * cell.size_setter.x, viewport_middle)
		cells.append(cell)
	for cell in cells:
		add_child(cell)
	set_process(true)  # enables drawing


func _draw():
	for cell_index in range(1, len(cells)):
		if cell_index == len(cells):
			continue
		var right_cell = cells[cell_index]
		var left_cell = cells[cell_index - 1]
		
		var offset = Vector2(right_cell.size.x / 2, right_cell.size.y / 2)
		
		draw_line(right_cell.position + offset, left_cell.position + offset, Color.WHITE)


func _process(delta):
	for i in range(iterations):
		update_ilne(speed)
	
	for cell in cells:
		cell.colorize()
	queue_redraw()


func _input(event):
	if not (event is InputEventMouseButton):
		return
	if not (event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	
	var mouse_x = get_global_mouse_position().x
	var cell_index: int
	for i in range(0, len(cells)):
		var cell = cells[i]
		if not (cell.position.x <= mouse_x and cell.position.x + cell.size.x > mouse_x):
			continue
		
		var ind: int
		for j in range(10):
			ind = i + j
			if ind >= len(cells):
				ind = ind % len(cells)
			cells[ind].height = - sin((float(j) / 9) * 3.1415)
		break


func update_ilne(delta):
	var size = cells.size()
	for i in range(size):
		var cell = cells[i]
		var cell_index = i
		
		var left_height = cells[(cell_index - 1 + size) % size].height
		var right_height = cells[(cell_index + 1) % size].height
		
		var avg_height = (left_height + right_height) / 2
		
		cell.velocity += cell.mobility * (avg_height - cell.height) * delta
		cell.height += cell.velocity * delta
		
		cell.position.y = cell.height * (viewport_middle / 4) + viewport_middle
