class_name ShopItem extends Control

@onready var item_ui: ItemUI = %ItemUI
@onready var price_label: Label = %PriceLabel

var data : Item : set = set_data
var price : int : set = set_price

func _ready() -> void:
	item_ui.loc = ItemUI.Location.SHOP
	item_ui.buy_signal.connect(buy_item)

func set_data(item : Item):
	data = item
	
	item_ui.data = data
	
	price_label.show()
	show()

func set_price(value : int):
	price = value
	
	price_label.text = str(value)

func buy_item():
	if DataManager.run.gold >= price:
		DataManager.run.gold -= price
		Audio.play_sfx(Audio.buy_sell)
		
		if data is Equipment:
			DataManager.run.equip_equipment(data)
			hide()
		else:
			DataManager.run.inventory.add_item_to_inventory(data)
			hide()
