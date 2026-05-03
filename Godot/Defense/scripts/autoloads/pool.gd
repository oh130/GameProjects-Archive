extends Node

# pathes.
const stage_path := "res://resources/datas/stages/"
const item_path := "res://resources/datas/items/"
const shop_item_path := "res://resources/datas/shop_items/"

# pools.
var stage_pool : Array[StageData]
var item_pool : Array[ItemData]
var shop_item_pool : Array[ItemData]

# execute only once when start game program.
func _init():
	init_pools_from_dir(stage_path, stage_pool, "StageData")
	init_pools_from_dir(item_path, item_pool, "ItemData")
	init_pools_from_dir(shop_item_path, shop_item_pool, "ItemData")

func init_pools_from_dir(path : String, pool : Array, type_hint := "Resource"):
	for res_name in DirAccess.open(path).get_files():
		var res := ResourceLoader.load(path + res_name, type_hint)
		pool.append(res)
