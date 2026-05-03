class_name ItemUI extends TextureRect

enum Location { INVENTORY, SHOP, REWARD }

@onready var count_label: Label = %CountLabel

var loc : Location
var data : Item : set = set_data
var count := 1 : set = set_count

signal get_reward_signal(item : Item)
signal buy_signal()

func _ready():
	count_label.hide()

func set_data(item : Item):
	data = item
	
	texture = data.icon

func set_count(value : int):
	count = value
	count_label.text = str(count)
	
	if count <= 1:
		count_label.hide()
	else:
		count_label.show()

func _on_gui_input(event : InputEvent):
	if GameManager.deny_input:
		return
	
	if event.is_action_pressed("left_mouse"):
		match loc:
			Location.INVENTORY:
				if data is Consumable and (data.area == Consumable.Area.ALWAYS\
				or (data.area == Consumable.Area.ON_COMBAT and SituationManager.on_combat)\
				or (data.area == Consumable.Area.EXCEPT_COMBAT and not SituationManager.on_combat))\
				and DataManager.run.focused_player:
					DataManager.run.use_consumable(data)
			Location.SHOP:
				buy_signal.emit()
			Location.REWARD:
				get_reward_signal.emit(data)
	elif event.is_action_pressed("right_mouse"):
		if data is Consumable and loc == Location.INVENTORY\
		and DataManager.run.shop.shop_opened:
			DataManager.run.sell_consumable(data as Consumable)

func _on_mouse_entered():
	SubInfoLayer.show_item_tooltip(self)

func _on_mouse_exited():
	SubInfoLayer.hide_item_tooltip()
