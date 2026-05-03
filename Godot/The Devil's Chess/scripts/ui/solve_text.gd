extends Label

func level_solved():
	Global.input_available = false
	await get_tree().create_timer(1).timeout
	await Global.show_node_by_tween(self)
	await get_tree().create_timer(1).timeout
	await Global.hide_node_by_tween(self)
