class_name Enhancement extends Resource

@export_group("Common")
@export var icon : Texture2D

@export_group("Special Enhancement")
@export var stats : Dictionary[Enum.Stat, Amount]
@export var passives : Array[Passive]

@export_group("Skill Enhancement")
@export var skill_idx : int

@export_group("Do Not Touch")
@export var selected : bool

func is_skill_enhancement() -> bool:
	return stats.is_empty() and passives.is_empty()
