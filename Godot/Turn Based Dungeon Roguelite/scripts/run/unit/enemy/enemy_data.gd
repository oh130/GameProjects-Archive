class_name EnemyData extends UnitData

@export_group("Information(Should Pre-Set)")
@export var sprite_width : float
@export var att_mods : Dictionary[Enum.Attribute, int] =\
{
	Enum.Attribute.IMPACT : 0,
	Enum.Attribute.SLASH : 0,
	Enum.Attribute.PIERCE : 0,
	Enum.Attribute.NATURE : 0,
	Enum.Attribute.ARCANE : 0,
	Enum.Attribute.MYSTIC : 0
}

@export_group("In-Game Variables(Don't Touch)")
@export var weaknesses : Array[Enum.Attribute]

func initialize():
	# before init health and energy, get level and get stat.
	var level := int(0.1 * DataManager.save_data.difficulty)
	for key in stat_up_per_level:
		stats[key].amount += stat_up_per_level[key] * level
	
	super.initialize()
	
	var first_attr : Enum.Attribute = Enum.Attribute.IMPACT
	var second_attr : Enum.Attribute = Enum.Attribute.IMPACT
	var first_val := -INF
	var second_val := -INF
	
	for key in att_mods:
		var val := att_mods[key]
		if val > first_val:
			second_val = first_val
			second_attr = first_attr
			first_val = val
			first_attr = key
		elif val > second_val:
			second_val = val
			second_attr = key
	
	weaknesses = [first_attr, second_attr]
