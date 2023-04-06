extends Node2D

@export var size: int = 10
@export var iterations: int = 10
@export var speed: float = 0.001

# Для того, чтобы следить, что энергия системы оставалась неизменной
var energy_add: float = 1
var energy_state: float

var cells: Array = Array()

var viewport_middle: float

var height_multiplier: float

@onready var cell_scene = load("res://scene/light_cell.tscn")


func _ready():
	energy_state = 0
	
	var viewport_width = get_viewport_rect().size.x
	var perfect_fit = Vector2.ONE * (viewport_width / size)
	viewport_middle = get_viewport_rect().size.y / 2
	for i in size:
		var cell: ColorRect = cell_scene.instantiate()
		cell.size_setter = perfect_fit
		cell.position = Vector2(i * cell.size_setter.x, viewport_middle)
		
		# making border
		if (i == 0 or i == size - 1):
			cell.mobility = 0.0
#		elif i > round(size / 2):
#			cell.mobility = 0.5
		
		cells.append(cell)
	
	for cell in cells:
		add_child(cell)
	
	set_process(true)


func _draw():
	for cell in cells:
		var cell_index = cells.find(cell, 0)
		
		var left_cell = cells[cell_index - 1]
		var right_cell = cells[cell_index + 1 if cell_index + 1 != size else 0]
		
		var offset = Vector2(cell.size.x / 2, cell.size.y / 2)
		
		draw_line(cell.position + offset, left_cell.position + offset, Color.WHITE)
		draw_line(cell.position + offset, right_cell.position + offset, Color.WHITE)


func _process(delta):
#	print(1 / delta)
	
	if speed == 0:
		return
	
	for i in range(iterations):
		update_ilne(speed)
	
	var energy = cells.reduce(func sum(accum, cell): return accum + abs(cell.velocity), 0)
	if energy != 0:
		cells.map(func damp(cell): cell.velocity *= energy_state / energy)
	
	for cell in cells:
		cell.colorize()
	queue_redraw()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_x = get_global_mouse_position().x
			var cell_index: int
			for cell in cells:
				if mouse_x > cell.position.x and mouse_x < cell.position.x + cell.size.x:
					cell_index = cells.find(cell)
			
			if cell_index:
				var spread = 5
				for offset in range(-spread, spread):
					var cell = cells[cell_index + offset]
					var energy_added = sin(offset)
					energy_state += abs(energy_add)
					cells[cell_index + offset].height = energy_added
			
			else:
				print("no cell selected")


func update_ilne(delta):
	for cell in cells:
		if not cell.mobility:
			continue
		
		var cell_index = cells.find(cell, 0)
		
		var left_height = cells[cell_index - 1].height
		var right_height = cells[cell_index + 1 if cell_index + 1 != size else 0].height
		
		var avg_height = (left_height + right_height) / 2
		
		cell.velocity += (cell.mobility) * (avg_height - cell.height) * delta
		cell.height += cell.velocity * delta
		
		cell.position.y = (cell.height * (viewport_middle / 2)) + viewport_middle
