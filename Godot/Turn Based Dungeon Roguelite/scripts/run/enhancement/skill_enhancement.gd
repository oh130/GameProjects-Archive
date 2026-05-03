class_name SkillEnhancement extends Resource
# NOTE: ALL information must be ADDED to skill.

@export_group("SkillEnhancement: Informations")
@export var repeat_time : int
@export var costs : Dictionary[Skill.Cost, int]
@export var self_conditions : Dictionary[Skill.Condition, int]
@export var target_conditions : Dictionary[Skill.Condition, int]

@export_group("SkillEnhancement: Skill Attributes")
@export var self_buff : Buff
@export var self_gain_statuses : Dictionary[Enum.Status, Amount]
@export var effects : Dictionary[SkillEffects.Effect, Amount]
@export var amount_effects : Dictionary[SkillEffects.AmountEffect, Amount]
@export var special_effects : Array[SkillEffects.SpecialEffect]

@export_group("SkillEnhancement: Skill Attributes Depand on Target")
@export var target_buff : Buff
@export var target_gain_statuses : Dictionary[Enum.Status, Amount]
@export var target_effects : Dictionary[SkillEffects.TargetEffect, Amount]
@export var target_amount_effects : Dictionary[SkillEffects.TargetAmountEffect, Amount]
@export var target_special_effects : Array[SkillEffects.TargetSpecialEffect]

@export_group("Do Not Touch")
@export var selected : bool
