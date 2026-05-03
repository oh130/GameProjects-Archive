class_name DashState extends State

@export var action_mediator : ActionMediator
@export var ground_state : State
@export var ghost_generator : GhostGenerator
@export var damageable : PlayerDamageable

#func state_input(event : InputEvent):
	#if event.is_action_pressed("attack"):
		#next_state = action_mediator.attack()

func on_enter():
	ghost_generator.active = true
	damageable.on_dash = true
	
func on_exit():
	character.velocity.y = 0
	ghost_generator.active = false
	damageable.on_dash = false
	
func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "dash":
		next_state = ground_state
		playback.travel("move")
