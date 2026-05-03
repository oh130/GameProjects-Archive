extends Node

const element_path := "res://resources/elements/appearable_elements/"
const item_path := "res://resources/items/"
const enemy_path := "res://resources/enemies/"

var element_pool : Array[ElementData]
var item_pool : Array[ItemData]
var enemy_pool : Array[EnemyData]

func _init():
	init_pools_from_dir(element_path, element_pool, "ElementData")
	init_pools_from_dir(item_path, item_pool, "ItemData")
	init_pools_from_dir(enemy_path, enemy_pool, "EnemyData")

func remove_item_in_pool(item : ItemData):
	item_pool.erase(item)

func init_pools_from_dir(path : String, pool : Array, type_hint : String):
	pool.clear()
	
	for res_name in DirAccess.open(path).get_files():
		var res := ResourceLoader.load(path + res_name, type_hint)
		pool.append(res)
