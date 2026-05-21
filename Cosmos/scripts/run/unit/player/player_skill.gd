class_name PlayerSkill extends Skill

@export_group("Player Skill")
@export var attack_attribute : Enum.Attribute # only if attack.
@export var stat_mods : Dictionary[Enum.Stat, int] =\
{
	Enum.Stat.CRIT : 0,
	Enum.Stat.CRIT_MUL : 0,
	Enum.Stat.ARMOR_PEN : 0,
	Enum.Stat.ARMOR_PEN_RATE : 0
}
@export var enhancement : SkillEnhancement
