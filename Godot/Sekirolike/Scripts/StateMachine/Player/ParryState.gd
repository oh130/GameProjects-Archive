class_name ParryState extends State

@export var ground_state : State
@export var damageable : Damageable

func on_enter():
	damageable.on_parry = true
	
func on_exit():
	damageable.on_parry = false
	
func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "parry":
		next_state = ground_state
