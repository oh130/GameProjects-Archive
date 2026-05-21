class_name BuffContainer extends Control

@onready var buff_ui: StatusUI = %BuffUI
@onready var debuff_ui: StatusUI = %DebuffUI
@onready var temp_buff_ui: StatusUI = %TempBuffUI
@onready var temp_debuff_ui: StatusUI = %TempDebuffUI

var buff_tooltip : String
var debuff_tooltip : String
var temp_buff_tooltip : String
var temp_debuff_tooltip : String

func _ready() -> void:
	buff_ui.mouse_entered.connect(on_buff_ui_mouse_entered.bind(0))
	buff_ui.mouse_exited.connect(on_buff_ui_mouse_exited)
	debuff_ui.mouse_entered.connect(on_buff_ui_mouse_entered.bind(1))
	debuff_ui.mouse_exited.connect(on_buff_ui_mouse_exited)
	temp_buff_ui.mouse_entered.connect(on_buff_ui_mouse_entered.bind(2))
	temp_buff_ui.mouse_exited.connect(on_buff_ui_mouse_exited)
	temp_debuff_ui.mouse_entered.connect(on_buff_ui_mouse_entered.bind(3))
	temp_debuff_ui.mouse_exited.connect(on_buff_ui_mouse_exited)

#
#func add_buff_anim():
	#buff_ui.animation_player.play("add")

func set_buffs(buff_arr : Array[RefinedBuff]):
	var buff_dict : Dictionary[Enum.Stat, int]
	
	var temp_buff_t := ""
	var temp_debuff_t := ""
	
	for buff in buff_arr:
		if buff.temp_buff_end_timing == Enum.Situation.NONE:
			# not temp buff.
			for key in buff.stat_buffs:
				if buff_dict.has(key):
					buff_dict[key] += buff.stat_buffs[key]
				else:
					buff_dict[key] = buff.stat_buffs[key]
		
		else:
			# temp buff.
			for key in buff.stat_buffs:
				if buff.stat_buffs[key] > 0:
					temp_buff_t += "%s %+d (%s)\n" % [SubInfoLayer.get_stat_icon(key),\
					buff.stat_buffs[key], tr(Enum.Situation.keys()[buff.temp_buff_end_timing])]
				else:
					temp_debuff_t += "%s %+d (%s)\n" % [SubInfoLayer.get_stat_icon(key),\
					buff.stat_buffs[key], tr(Enum.Situation.keys()[buff.temp_buff_end_timing])]
	
	temp_buff_tooltip = temp_buff_t
	temp_debuff_tooltip = temp_debuff_t
	
	temp_buff_ui.count = 1 if temp_buff_t != "" else 0
	temp_debuff_ui.count = 1 if temp_debuff_t != "" else 0
	
	var buff_t := ""
	var debuff_t := ""
	for key in buff_dict:
		if buff_dict[key] < 0:
			debuff_t += "%s %+d\n" % [SubInfoLayer.get_stat_icon(key), buff_dict[key]]
		else:
			buff_t += "%s %+d\n" % [SubInfoLayer.get_stat_icon(key), buff_dict[key]]
	
	buff_tooltip = buff_t
	debuff_tooltip = debuff_t
	
	buff_ui.count = 1 if buff_t != "" else 0
	debuff_ui.count = 1 if debuff_t != "" else 0

func on_buff_ui_mouse_entered(i : int):
	var buff_id : String
	var tooltip_str : String
	
	match i:
		0:
			buff_id = "BUFF"
			tooltip_str = buff_tooltip
		1:
			buff_id = "DEBUFF"
			tooltip_str = debuff_tooltip
		2:
			buff_id = "TEMP_BUFF"
			tooltip_str = temp_buff_tooltip
		3:
			buff_id = "TEMP_DEBUFF"
			tooltip_str = temp_debuff_tooltip
	
	SubInfoLayer.show_status_tooltip(buff_id, tooltip_str, get_global_mouse_position())

func on_buff_ui_mouse_exited():
	SubInfoLayer.hide_status_tooltip()
