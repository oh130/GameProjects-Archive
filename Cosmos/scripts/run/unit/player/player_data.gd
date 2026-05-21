class_name PlayerData extends UnitData

const START_EXP := 50
const MAXIMUM_SELECTED_SKILLS := 6

@export_group("Information(Should Pre-Set)")
@export var preview : Texture2D
@export var portrait : Texture2D
@export var counter_attribute : Enum.Attribute
@export var assist_attribute : Enum.Attribute
@export var enhancements : Array[Enhancement]
@export var special_stats : Dictionary[Enum.SpecialStat, int]

@export_group("In-Game Variables(Don't Touch)")
@export var selected_skills : Array[PlayerSkill]
@export var counter : PlayerSkill
@export var assist : PlayerSkill
@export var equipments : Dictionary[Equipment, int]
@export var cur_exp : int
@export var cur_exp_for_up : int = START_EXP
@export var enhancement_reroll_chance := 2

func initialize():
	super.initialize()
	
	# why duplicate: if not, it is reference, so resource cannot save it's own data.
	for i in skills.size():
		skills[i] = skills[i].duplicate()
		if skills[i].self_buff:
			skills[i].self_buff = skills[i].self_buff.duplicate()
		if skills[i].target_buff:
			skills[i].target_buff = skills[i].target_buff.duplicate()
	
	counter = SubInfoLayer.def_counter.duplicate()
	assist = SubInfoLayer.def_assist.duplicate()
	counter.attack_attribute = counter_attribute
	assist.attack_attribute = assist_attribute
	
	# default select skill.
	for i in PlayerData.MAXIMUM_SELECTED_SKILLS:
		if skills.size() <= i:
			break
		selected_skills.append(skills[i])
