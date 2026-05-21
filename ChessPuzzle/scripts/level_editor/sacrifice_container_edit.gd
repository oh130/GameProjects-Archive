extends Node

@onready var table = $".."
@onready var devil = $"../Devil"

var sacrifice_scene : PackedScene = preload("res://scenes/instances/sacrifice.tscn")

var sacrifice_slots : Array[Sacrifice]
var cur_selected_sacrifice : Sacrifice

signal show_movable_cell(_coord_arr : Array[Vector2i])
signal select_canceled_signal()

func _ready():
	init_sacrifices()

func init_sacrifices():
	for i in Global.SAC_TYPE.size():
		var sacrifice = sacrifice_scene.instantiate()
		add_child(sacrifice)
		
		sacrifice.pressed.connect(selected.bind(sacrifice))
		
		sacrifice_slots.append(sacrifice)

func create_sacrifices(piece_arr : Dictionary):
	cur_selected_sacrifice = null
	
	for i in piece_arr.keys():
		sacrifice_slots[i].remove_sacrifice_all()
		for j in piece_arr[i]:
			sacrifice_slots[i].add_sacrifice()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if Global.input_available:
				select_canceled()

func selected(_sacrifice : Sacrifice):
	if _sacrifice == cur_selected_sacrifice:
		return
	
	select_canceled()
	
	cur_selected_sacrifice = _sacrifice
	cur_selected_sacrifice.remove_sacrifice()
	set_effect_of_sacrifice(_sacrifice.sac_type)

func select_canceled():
	if cur_selected_sacrifice == null:
		return
	
	cur_selected_sacrifice.add_sacrifice()
	cur_selected_sacrifice = null
	emit_signal("select_canceled_signal")

func select_consumed(_trash : Vector2i):
	cur_selected_sacrifice = null

func set_effect_of_sacrifice(_sac_type : int):
	emit_signal("show_movable_cell", Global.get_sacrifice_effect_pos(devil.coord, _sac_type, table.cell_obj_checker))
