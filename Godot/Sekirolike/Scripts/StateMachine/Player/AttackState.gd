class_name AttackState extends State

@export var action_mediator : ActionMediator
@export var ground_state : State

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "attack":
		next_state = ground_state
