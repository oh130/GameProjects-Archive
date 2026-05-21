extends TextureRect

var data : EnemyData : set = set_data

func set_data(enemy_data : EnemyData):
	data = enemy_data
	
	if not is_node_ready():
		await ready
	
	texture = data.sprite
