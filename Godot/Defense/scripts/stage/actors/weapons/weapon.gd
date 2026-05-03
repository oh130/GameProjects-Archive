class_name Weapon extends Node2D

const ARRIVE_TIME := 1

var data : ArmamentData

func weapon_effect(pos : Vector2):
	position = pos - Vector2(0,0)
	
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "position", pos, ARRIVE_TIME)
	await tween.finished
	
	AttackManager.wide_attack(pos, data.reach, data.damage, data.armor_penetration)
	queue_free()
