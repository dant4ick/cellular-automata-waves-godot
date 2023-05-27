extends Node2D

var cells: Array = Array()

var size: int = 52
var perfect_fit: Vector2

const DEFAULT_SPEED: int = 1
var speed: int

const DEFAULT_DELTA: float = 0.01
var time_delta: float

var is_border: bool = false
var is_lens: bool = false
var is_slits: bool = false

@onready var cell_scene = load("res://scene/wave_cell.tscn")

func _ready():
	speed = DEFAULT_SPEED
	time_delta = DEFAULT_DELTA
	
	var viewport_size: Vector2 = get_viewport_rect().size
	var viewport_width: float = viewport_size.x
	
	perfect_fit = Vector2.ONE * floorf(viewport_width / size)
	generate_playground()
	

func generate_structures():
	for i in size:
		for j in size:
			var cell = cells[i][j]
			
			# double-slit experiment
			if i == round(size * 0.8) and j != round(size * 0.3) and j != round(size - size * 0.3) or (i == (size - 2) and j != round(size / 2)):
				cell.mobility = 0 if is_slits else 1
			
			# making border
			if (i == 0 or i == size - 1) or (j == 0 or j == size - 1):
				cell.mobility = 0 if is_border else 1
			
			# glass lens
			if ((i - size * 0.5) ** 2  + (j - size * 0.5) ** 2) <= 15 ** 2:
				cell.mobility = 0.4 if is_lens else 1


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
		cells.append(row)
	
	for row in cells:
		for cell in row:
			add_child(cell)
			var cell_index = cells.find(cell, 0)
			var row_index = cells.find(row, 0)
	
	generate_structures()


func _input(event):
	if not (event is InputEventMouseButton):
		return
	if not (event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	
	var mouse_pos = get_global_mouse_position()
	var cell_index_x: int
	var cell_index_y: int
	for row_index in range(len(cells)):
		var row = cells[row_index]
		for i in range(len(row)):
			var cell = row[i]
			if mouse_pos.x >= cell.position.x and mouse_pos.x < cell.position.x + cell.size.x and mouse_pos.y >= cell.position.y and mouse_pos.y < cell.position.y + cell.size.y:
				cell_index_x = i
				cell_index_y = row_index
		
	if cell_index_x:
		for x in range(-3, 4):
			for y in range(-3, 4):
				var cell = cells[(cell_index_y + y) % size][(cell_index_x + x) % size]
				var new_h = max(cell.height, 3 - sqrt(x**2 + y**2))
				if cell.mobility == 0:
					continue
				cell.height = new_h
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
	set_process(false)
	for i in size:
		for j in size:
			cells[i][j].height = 0
			cells[i][j].velocity = 0
	speed = DEFAULT_SPEED
	time_delta = DEFAULT_DELTA
	set_process(true)


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
	generate_structures()


func _on_is_slits_toggled(button_pressed):
	is_slits = button_pressed
	generate_structures()


func _on_is_lens_toggled(button_pressed):
	is_lens = button_pressed
	generate_structures()
