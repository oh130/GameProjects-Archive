class_name Buff extends Resource

@export_group("Attributes")
@export var temp_buff_end_timing : Enum.Situation
@export var stat_buffs : Dictionary[Enum.Stat, Amount]

func create_refind_buff(stats : Dictionary[Enum.Stat, int]) -> RefinedBuff:
	var ref_buff = RefinedBuff.new()
	
	ref_buff.temp_buff_end_timing = temp_buff_end_timing
	for key in stat_buffs:
		ref_buff.stat_buffs[key] = stat_buffs[key].apply_ratios(stats)
	
	return ref_buff
