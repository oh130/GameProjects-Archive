extends CanvasLayer

const POP_UP_SCENE := preload("res://scenes/pop_up.tscn")

@onready var pop_ups = %PopUps

func make_popup(des : String, conf_c : Callable):
	var pop_up := POP_UP_SCENE.instantiate()
	pop_up.set_popup(des, conf_c)
	pop_ups.add_child(pop_up)

func delete_all_popup():
	for child in pop_ups.get_children():
		child.queue_free()
