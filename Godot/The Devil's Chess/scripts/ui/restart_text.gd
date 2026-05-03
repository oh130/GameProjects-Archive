extends Label

func show_text():
	await Global.show_node_by_tween(self)
	await get_tree().create_timer(1).timeout
	await Global.hide_node_by_tween(self)
