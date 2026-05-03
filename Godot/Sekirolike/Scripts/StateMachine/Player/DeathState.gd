class_name DeathState extends State

func _on_damageable_on_hit():
	emit_signal("interrupt_state", self)
	playback.travel("death")

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "death":
		get_parent().get_parent().queue_free()
