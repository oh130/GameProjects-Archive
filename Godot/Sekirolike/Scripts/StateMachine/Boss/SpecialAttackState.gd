extends State

@export var move_state : State

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "double_attack":
		next_state = move_state
