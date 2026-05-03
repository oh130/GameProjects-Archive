extends Control

@onready var table = $".."

var cur_chosen_sac : int

var cell_scene : PackedScene = preload("res://scenes/instances/cell.tscn")
var cells : Array[Array]

signal act_command(_coord : Vector2i, _cur_chosen_sac : int)
signal show_info(_obj : Node, _additional_type : int)
signal show_atk_area(_enemy : Enemy)
signal hide_info()
signal hide_atk_area()

func _ready():
	init_cells()

func init_cells():
	for i in 8:
		var arr : Array[Node] = []
		for j in 8:
			var cell = cell_scene.instantiate()
			add_child(cell)
			cell.coord = Vector2i(j,i)
			cell.pressed.connect(board_cell_clicked.bind(cell.coord))
			cell.mouse_entered.connect(on_cell_mouse_entered.bind(cell.coord))
			cell.mouse_exited.connect(on_cell_mouse_exited)
			arr.append(cell)
		cells.append(arr)

func change_cur_chosen_sac(_cur_chosen_sac : int):
	cur_chosen_sac = _cur_chosen_sac

func board_cell_show(coord_arr : Array[Vector2i]):
	board_cell_hide_all()
	
	for coord in coord_arr:
		cells[coord.y][coord.x].set_able()

func board_cell_hide_all():
	for arr in cells:
		for cell in arr:
			cell.set_disable()

func board_cell_clicked(coord : Vector2i):
	board_cell_hide_all()
	emit_signal("act_command", coord, cur_chosen_sac)

func on_cell_mouse_entered(coord : Vector2i):
	var target_obj : Node = table.cell_obj_checker[coord.y][coord.x]
	if target_obj is Enemy:
		emit_signal("show_info", target_obj, target_obj.piece_type)
		emit_signal("show_atk_area", target_obj)
	else:
		emit_signal("show_info", target_obj, 0)

func on_cell_mouse_exited():
	emit_signal("hide_info")
	emit_signal("hide_atk_area")
