class_name Item extends TextureRect

enum ITEM_LOC { BAG, REWARD }

@export var item_loc : ITEM_LOC

var data : ItemData : set = set_data

func set_data(item_data : ItemData):
	data = item_data
	
	if not is_node_ready():
		await ready
	
	texture = data.icon

func _on_gui_input(event : InputEvent):
	if event.is_action_pressed("left_mouse"):
		match item_loc:
			ITEM_LOC.REWARD:
				EventBus.reward_selected.emit()
				adding_item()

func adding_item():
	GameManager.data_manager.add_item_to_inventory(data)
	
	queue_free()

func _on_mouse_entered():
	SubInfoLayer.show_tooltip_box(data.id, data.description, global_position)

func _on_mouse_exited():
	SubInfoLayer.hide_tooltip_box()
