extends Control

signal item_drop_end()

func _on_continue_pressed():
	emit_signal("item_drop_end")
	queue_free()
