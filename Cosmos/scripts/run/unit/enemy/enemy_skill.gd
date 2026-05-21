class_name EnemySkill extends Skill

@export_group("Enemy Skill")
@export var is_pre_turn_skill : bool
@export var has_priority : bool
@export var stat_mods : Dictionary[Enum.Stat, int] =\
{
	Enum.Stat.ARMOR_PEN : 0,
	Enum.Stat.ARMOR_PEN_RATE : 0
}
