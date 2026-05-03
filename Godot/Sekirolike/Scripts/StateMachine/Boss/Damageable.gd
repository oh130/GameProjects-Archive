class_name BossDamageable extends Node

signal on_hit()

@export var character : CharacterBody2D
@export var damageableIndex : int
@export var maxHp : float

var health : float :
	set(value):
		if health > value:
			emit_signal("on_hit", value)
			match damageableIndex:
				0 : GlobalData.emit_signal("player_hp_changed", value)
				1 : GlobalData.emit_signal("boss_hp_changed", value)
		health = value

func _ready():
	health = maxHp

func hit(damage : int, enemy : CharacterBody2D):
	health -= damage

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "death":
		get_parent().queue_free()
