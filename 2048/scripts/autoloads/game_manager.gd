extends Node

# run state booleans.
var deny_input := false
var on_combat := false

# in game.
var data_manager : DataManager
var board : Board
var player : Player
var enemy : Enemy

func shake(thing: Control, strength: float = 20, duration: float = 0.1):
	if not thing:
		return

	var orig_pos := thing.position
	var shake_count := 10
	var tween := create_tween()
	
	for i in shake_count:
		var shake_offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
		var target := orig_pos + strength * shake_offset
		if i % 2 == 0: 
			target = orig_pos
		tween.tween_property(thing, "position", target, duration / float(shake_count))
		strength *= 0.75
	
	tween.finished.connect(func(): thing.position = orig_pos)
