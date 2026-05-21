extends Node

var camera : Camera2D
# when crit, exhaust, attack break, defenseless, this value added.
var camera_zoom_force := 0

func skill_anim(caster : Unit, targets : Array[Unit], is_friendly : bool):
	# attack animation.
	if not is_friendly:
		if targets.front() is Enemy:
			var zoom_vec := (1 + 0.1 * camera_zoom_force) * Vector2.ONE
			var tween := create_tween()
			tween.set_parallel(false)
			tween.tween_property(camera, "zoom", zoom_vec, 0.1)
			tween.tween_property(camera, "zoom", Vector2.ONE, 0.5)
		
		if camera_zoom_force > 0:
			Engine.time_scale = 0.1
			var tween := create_tween()
			tween.tween_property(Engine, "time_scale", 1, 0.1)
		camera_zoom_force = 0
		
		GameManager.shake(camera, Vector2.ZERO)
		GameManager.shake_vertical(caster.sprite, caster.orig_pos)
		for target in targets:
			GameManager.shake(target.sprite, target.orig_pos)
	
	await get_tree().create_timer(0.5).timeout
