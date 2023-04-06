extends Node2D

@export var size: int = 10

var cells: Array = Array()

var accum_delta: float

@onready var cell_scene = load("res://scene/light_cell.tscn")

func _ready():
	var viewport_width = get_viewport_rect().size.x
	var perfect_fit = Vector2.ONE * (viewport_width / size)
	
	for i in size:
		var row = Array()
		for j in size:
			var cell: ColorRect = cell_scene.instantiate()
			cell.size_setter = perfect_fit
			cell.position = Vector2(j * cell.size_setter.x, i * cell.size_setter.y)
			row.append(cell)
			
			# making border
			if (i == 0 or i == size - 1) or (j == 0 or j == size - 1):
				cell.mobility = 0
			# double-slit experiment
#			elif i == round(size / 2) and j != round(size * 0.4) and j != round(size * 0.6) or (i == round(size * 0.6) and j != round(size / 2)):
#				cell.mobility = 0
#			elif ((i - size / 2) ** 2  + (j - size / 2) ** 2) <= 10 ** 2:
#				cell.mobility = 0.7
		cells.append(row)
	
	for row in cells:
		for cell in row:
			add_child(cell)
			var cell_index = cells.find(cell, 0)
			var row_index = cells.find(row, 0)
	
	accum_delta = 0


func _process(delta):
	update_grid(0.1)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			var cell_index_x: int
			var cell_index_y: int
			for row in cells:
				var row_index = cells.find(row)
				for cell in row:
					if mouse_pos.x > cell.position.x and mouse_pos.x < cell.position.x + cell.size.x and mouse_pos.y > cell.position.y and mouse_pos.y < cell.position.y + cell.size.y:
						cell_index_x = cells[row_index].find(cell)
						cell_index_y = row_index
			
			if cell_index_x:
				cells[cell_index_y][cell_index_x].height = 1
			else:
				print("no cell selected")



func update_grid(delta):
	for row in cells:
		var row_index = cells.find(row, 0)
		for cell in row:
			var cell_index = row.find(cell, 0)
			
			var left_height = row[cell_index - 1].height
			var right_height = row[cell_index + 1 if cell_index + 1 != size else 0].height
			var up_height = cells[row_index - 1][cell_index].height
			var down_height = cells[row_index + 1 if row_index + 1 != size else 0][cell_index].height
			
			var avg_height = (left_height + right_height + up_height + down_height) / 4
			
			cell.velocity += (cell.mobility) * (avg_height - cell.height) * delta
			cell.height += cell.velocity * delta
			cell.colorize()
