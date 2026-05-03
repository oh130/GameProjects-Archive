extends State

@export var ground_state : State
@export var death_state : State
@export var groggy : float
@export var attackHitBox : Area2D

func _on_damageable_on_hit(hp : int):
	if hp > 0:
		character.groggy_gage += 10
	else:
		emit_signal("interrupt_state", death_state)
		playback.travel("death")

func on_exit():
	attackHitBox.monitoring = false

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "hit":
		next_state = ground_state

func _on_boss_on_groggy():
	emit_signal("interrupt_state", self)
	playback.travel("hit")
