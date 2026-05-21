class_name ShopItem extends Button

@onready var cost: Label = %Cost

var data : ItemData : set = set_data

func set_data(item_data : ItemData):
	data = item_data
	
	if not is_node_ready():
		await ready
	
	icon = data.sprite if data else null
	
	cost.text = str(item_data.shop_cost)
