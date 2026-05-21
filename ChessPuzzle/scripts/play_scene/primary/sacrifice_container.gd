extends Node

@onready var table = $".."
@onready var devil = $"../Objects/Devil"
@onready var chosen_info = $"../UI/ChosenInfo"
@onready var remain_soul_text = $"../UI/Soul/RemainSoul"

@export var remain_soul : int :
	set(value):
		remain_soul = value
		remain_soul_text.text = str(value)

var sacrifice_scene : PackedScene = preload("res://scenes/instances/sacrifice.tscn")

var sacrifice_slots : Array[Node]
var cur_sacrifice : Sacrifice

var on_second_act : bool

signal show_sacrifice_effect_cells(_coord_arr : Array[Vector2i])
signal select_signal(sac_type : int)
signal select_canceled_signal()

func _ready():
	sacrifice_slots = get_children()
	
	for i in sacrifice_slots.size():
		sacrifice_slots[i].pressed.connect(selected.bind(sacrifice_slots[i]))
		sacrifice_slots[i].mouse_entered.connect(chosen_info.show_info.bind(sacrifice_slots[i],i))
		sacrifice_slots[i].mouse_exited.connect(chosen_info.hide_info)

func init_sacrifice_and_soul(cur_chap : int, cur_lv : int):
	cur_sacrifice = null
	on_second_act = false
	
	remain_soul = Level.level_info[str(cur_chap)][str(cur_lv)]["usable_soul"]
	
	for i in Level.level_info[str(cur_chap)][str(cur_lv)]["usable_sacrifice"]:
		sacrifice_slots[i].set_able()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if Global.input_available and event.button_index == MOUSE_BUTTON_RIGHT:
			select_canceled()

func selected(_sacrifice : Sacrifice):
	if not Global.input_available or on_second_act:
		return
	if _sacrifice.cost > remain_soul:
		return
	if _sacrifice.sac_type == Global.SAC_TYPE.JUDGMENT or _sacrifice.sac_type == Global.SAC_TYPE.STEALTH:
		pass
	else:
		select_canceled()
		
		cur_sacrifice = _sacrifice
		remain_soul -= cur_sacrifice.cost
		set_effect_of_sacrifice(_sacrifice.sac_type)

func select_canceled():
	if cur_sacrifice == null or on_second_act:
		return
	
	remain_soul += cur_sacrifice.cost
	cur_sacrifice = null
	
	emit_signal("select_canceled_signal")

func select_consumed(_coord : Vector2i):
	if cur_sacrifice.sac_type == Global.SAC_TYPE.PAWN and _coord.y == 0:
		remain_soul += 4
	
	cur_sacrifice = null
	on_second_act = false
	
	emit_signal("select_canceled_signal")

func on_voodoo_effect(_piece_type : int):
	on_second_act = true
	
	emit_signal("show_sacrifice_effect_cells", Global.enemy_piece_atk_coords(devil.coord, _piece_type, table.cell_obj_checker))

func set_effect_of_sacrifice(_sac_type : int):
	emit_signal("select_signal", _sac_type)
	
	var effect_cells : Array[Vector2i]
	
	match _sac_type:
		Global.SAC_TYPE.VOODOO:
			for i in 8:
				for j in 8:
					var _obj : Node = table.cell_obj_checker[i][j]
					if _obj is Enemy and _obj.piece_type != Global.PIECE_TYPE.NONE_ATK:
						effect_cells.append(Vector2i(j,i))
						
		Global.SAC_TYPE.DIM_REVERSAL:
			for i in 8:
				for j in 8:
					var _obj : Node = table.cell_obj_checker[i][j]
					if _obj != null and not _obj is Exit:
						effect_cells.append(Vector2i(j,i))
						
		_:
			effect_cells = Global.get_sacrifice_effect_pos(devil.coord, _sac_type, table.cell_obj_checker)
			
	emit_signal("show_sacrifice_effect_cells", effect_cells)
