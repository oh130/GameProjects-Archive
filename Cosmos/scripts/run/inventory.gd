class_name Inventory extends Control

const ITEM_UI_SCENE := preload("res://scenes/run/item/item_ui.tscn")

@onready var consumable_container: FlowContainer = %ConsumableContainer

func load_inventory():
	for item in DataManager.save_data.consumables:
		var item_inst := ITEM_UI_SCENE.instantiate()
		consumable_container.add_child(item_inst)
		item_inst.data = item
		item_inst.count = DataManager.save_data.consumables[item]

func add_item_to_inventory(item : Consumable):
	if DataManager.save_data.consumables.has(item):
		for item_ui : ItemUI in consumable_container.get_children():
			if item_ui.data == item:
				item_ui.count += 1
		
		DataManager.save_data.consumables[item] += 1
		return
	
	var item_inst := ITEM_UI_SCENE.instantiate()
	consumable_container.add_child(item_inst)
	DataManager.save_data.consumables[item] = 1
	item_inst.data = item
	item_inst.count = 1

func erase_item_from_inventory(item : Consumable):
	DataManager.save_data.consumables[item] -= 1
		
	for item_ui : ItemUI in consumable_container.get_children():
		if item_ui.data == item:
			item_ui.count -= 1
			if item_ui.count == 0:
				DataManager.save_data.consumables.erase(item)
				item_ui.queue_free()
				return
