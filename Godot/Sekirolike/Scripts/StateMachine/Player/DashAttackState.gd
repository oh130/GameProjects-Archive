class_name DashAttackState extends State

@export var action_mediator : ActionMediator
@export var attack_hitbox : Area2D
@export var damageable : PlayerDamageable
@export var ghost_generator : GhostGenerator
@export var ground_state : State

func on_enter():
	attack_hitbox.monitoring = true
	ghost_generator.active = true
	damageable.on_dash_attack = true

func on_exit():
	attack_hitbox.monitoring = false
	ghost_generator.active = false
	damageable.on_dash_attack = false

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "dash_attack":
		next_state = ground_state
