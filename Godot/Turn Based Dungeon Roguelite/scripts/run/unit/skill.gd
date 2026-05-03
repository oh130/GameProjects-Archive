class_name Skill extends Resource

enum Target
{
	SELF,
	ALLY,
	ALLY_EXCEPT_SELF,
	ALL_ALLY,
	ENEMY,
	ALL_ENEMY
}

enum Condition
{
	HEALTH_MORE_THAN,
	HEALTH_LESS_THAN,
	
	BREAK,
	EXHAUSTED,
}

# additional cost except action point.
enum Cost
{
	HEALTH,
	ENERGY,
	
	# boolean cost.
	ALL_ENERGY,
	
	# about target.
	TARGET_ALL_BREAK,
}

@export_group("FX")
@export var icon : Texture2D
@export var vfx : VFX
@export var sfx : AudioStream

@export_group("Informations")
@export var repeat_time := 1
@export var target : Target
@export var costs : Dictionary[Cost, int]
@export var self_conditions : Dictionary[Condition, int]
@export var target_conditions : Dictionary[Condition, int]

@export_group("Skill Attributes")
@export var self_buff : Buff
@export var self_gain_statuses : Dictionary[Enum.Status, Amount]
@export var effects : Dictionary[SkillEffects.Effect, Amount]
@export var amount_effects : Dictionary[SkillEffects.AmountEffect, Amount]
@export var special_effects : Array[SkillEffects.SpecialEffect]

@export_group("Skill Attributes Depand on Target")
@export var target_buff : Buff
@export var target_gain_statuses : Dictionary[Enum.Status, Amount]
@export var target_effects : Dictionary[SkillEffects.TargetEffect, Amount]
@export var target_amount_effects : Dictionary[SkillEffects.TargetAmountEffect, Amount]
@export var target_special_effects : Array[SkillEffects.TargetSpecialEffect]

func is_friendly() -> bool:
	return target in [Target.ALLY, Target.ALLY_EXCEPT_SELF, Target.ALL_ALLY]
