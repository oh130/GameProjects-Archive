class_name CombatSkillUI extends SkillUI

signal combat_skill_select_signal(data : Skill)

func _ready() -> void:
	super._ready()
	toggled.connect(_on_toggled)

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		combat_skill_select_signal.emit(data)
