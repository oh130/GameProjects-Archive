class_name RefinedBuff extends RefCounted
# buffs that already applied ratios.

var temp_buff_end_timing : Enum.Situation
var stat_buffs : Dictionary[Enum.Stat, int]

func create_copy() -> RefinedBuff:
	var ref_buff := RefinedBuff.new()
	ref_buff.stat_buffs = stat_buffs.duplicate()
	return ref_buff
