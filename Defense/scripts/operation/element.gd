class_name Element extends Button

var data : ItemData : set = set_data

func set_data(item_data : ItemData):
	data = item_data
	
	if not is_node_ready():
		await ready
	
	icon = data.sprite if data else null
