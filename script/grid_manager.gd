extends Node2D

var size: int = 52
var perfect_fit: Vector2

var cells: Array = Array()

const DEFAULT_SPEED: int = 1
var speed: int

const DEFAULT_DELTA: float = 0.01
var time_delta: float

var is_border: bool = false
var is_lens: bool = false
var is_slits: bool = false

var accum_delta: float

@onready var cell_scene = load("res://scene/light_cell.tscn")

func _ready():
	speed = DEFAULT_SPEED
	time_delta = DEFAULT_DELTA
	
	var viewport_size: Vector2 = get_viewport_rect().size
	var viewport_width: float = viewport_size.x
	
	perfect_fit = Vector2.ONE * floorf(viewport_width / size)
	generate_playground()
	

func generate_playground():
	if get_child_count():
		cells = Array()
		for child in get_children():
			remove_child(child)
	
	for i in size:
		var row = Array()
		for j in size:
			var cell: ColorRect = cell_scene.instantiate()
			cell.size_setter = perfect_fit
			cell.position = Vector2(j * cell.size_setter.x, i * cell.size_setter.y)
			row.append(cell)
			
#			# making border
			if is_border and ((i == 0 or i == size - 1) or (j == 0 or j == size - 1)):
				cell.mobility = 0
			
#			double-slit experiment
			if is_slits and (i == round(size * 0.8) and j != round(size * 0.3) and j != round(size - size * 0.3) or (i == (size - 2) and j != round(size / 2))):
				cell.mobility = 0

#			glass lens
			if is_lens and (((i - size * 0.64) / 0.6) ** 2  + ((j - size/2) / 3) ** 2) <= 10 ** 2:
				cell.mobility = (((i - size * 0.64) / 0.6) ** 2  + ((j - size/2) / 3) ** 2) / (10.5 ** 2)

		cells.append(row)
	
	for row in cells:
		for cell in row:
			add_child(cell)
			var cell_index = cells.find(cell, 0)
			var row_index = cells.find(row, 0)
	
	accum_delta = 0


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


func _process(delta):
	for i in range(speed):
		update_grid(time_delta)
	
	for row in cells:
		for cell in row:
			cell.colorize()


func update_grid(delta):
	var size = cells.size()

	for i in range(size):
		var row = cells[i]
		var prev_row = cells[(i - 1 + size) % size]
		var next_row = cells[(i + 1) % size]
		
		for j in range(row.size()):
			var cell = row[j]
			var prev_cell = row[(j - 1 + row.size()) % row.size()]
			var next_cell = row[(j + 1) % row.size()]
			
			var left_height = prev_cell.height
			var right_height = next_cell.height
			var up_height = prev_row[j].height
			var down_height = next_row[j].height
			
			var avg_height = (left_height + right_height + up_height + down_height) / 4
			
			cell.velocity += cell.mobility * (avg_height - cell.height) * delta
			cell.height += cell.velocity * delta


func _on_restart_pressed():
	generate_playground()
	speed = DEFAULT_SPEED
	time_delta = DEFAULT_DELTA


func _on_upd_per_frame_value_changed(value):
	speed = int(value)


func _on_time_delta_value_changed(value):
	time_delta = value


func _on_v_slider_value_changed(value):
	for row in cells:
		for cell in row:
			cell.exposure = value


func _on_is_border_toggled(button_pressed):
	is_border = button_pressed


func _on_is_slits_toggled(button_pressed):
	is_slits = button_pressed


func _on_is_lens_toggled(button_pressed):
	is_lens = button_pressed
