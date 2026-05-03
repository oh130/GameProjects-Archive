@tool
extends EditorScript

const SAVE_PATH := "res://resources/common_data/pool_res.tres"

const player_path := "res://resources/players/"
const player_data_base_path := "res://resources/player_datas/"

const uncommon_eq_path := "res://resources/items/equipments/uncommon/"
const rare_eq_path := "res://resources/items/equipments/rare/"
const consumable_path := "res://resources/items/consumables/"

const chapter_path := "res://resources/chapters/"
const encounter_path := "res://resources/encounters/"

const enemy_group_path := "res://resources/enemies/groups/enemy_groups/"
const elite_group_path := "res://resources/enemies/groups/elite_groups/"
const boss_group_path := "res://resources/enemies/groups/boss_groups/"

func _run() -> void:
	var pool_res := PoolRes.new()
	
	init_pools_from_dir(player_path, pool_res.player_pool, "PlayerData")
	init_pools_from_dir(uncommon_eq_path, pool_res.uncommon_eq_pool, "Equipment")
	init_pools_from_dir(rare_eq_path, pool_res.rare_eq_pool, "Equipment")
	init_pools_from_dir(consumable_path, pool_res.consumable_pool, "Consumable")
	init_pools_from_dir(chapter_path, pool_res.chapter_pool, "Chapter")
	init_pools_from_dir(encounter_path, pool_res.encounter_pool, "EncounterData")
	init_pools_from_dir(enemy_group_path, pool_res.enemy_group_pool, "EnemyGroup")
	init_pools_from_dir(elite_group_path, pool_res.elite_group_pool, "EnemyGroup")
	init_pools_from_dir(boss_group_path, pool_res.boss_group_pool, "EnemyGroup")
	
	for p in pool_res.player_pool:
		get_player_sub_resources(p)
	
	for group in pool_res.enemy_group_pool:
		for e in group.enemy_list:
			get_enemy_sub_resources(e)
	
	if ResourceSaver.save(pool_res, SAVE_PATH) == OK:
		print("Pool Generate Complete")
	else:
		print("Error Occured")

# It can search recursively.
func init_pools_from_dir(path: String, pool: Array, type_hint: String):
	if not path.ends_with("/"):
		path += "/"
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				init_pools_from_dir(path + file_name, pool, type_hint)
			elif not dir.current_is_dir() and file_name.get_extension() in ["tres", "res"]:
				var res := ResourceLoader.load(path + file_name, type_hint)
				res.resource_name = get_id(res)
				pool.append(res)
				
			file_name = dir.get_next()
		
		dir.list_dir_end()

func get_id(val : Resource) -> String:
	var clean_name := val.get_path().get_file().get_basename()
	var pos := clean_name.find("_")
	if pos != -1 and clean_name[pos - 1].is_valid_int():
		clean_name = clean_name.substr(pos + 1)
	
	return clean_name.to_upper()

#func init_players():
	#var players : Array[PlayerData] = []
	#init_pools_from_dir(player_path, players, "PlayerData")
	#
	#for p in players:
		#var dup := p.duplicate()
		#dup.skills = []
		#var skill_path := player_data_base_path + p.get_path().get_file().get_basename() + "/skills"
		#init_pools_from_dir(skill_path, dup.skills, "Skill")
		#ResourceSaver.save(dup, p.get_path())

func get_player_sub_resources(player_data : PlayerData):
	var sub_res_base_dir := player_data_base_path + player_data.get_path().get_file().get_basename()
	
	## skills.
	#var skills : Array[Skill] = []
	var skill_path := sub_res_base_dir + "/skills"
	init_pools_from_dir(skill_path, [], "Skill")
	var enh_path := sub_res_base_dir + "/enhancements"
	init_pools_from_dir(enh_path, [], "Enhancement")
	#player_data.skills = skills
	#print(player_data.skills)

func get_enemy_sub_resources(enemy_data : EnemyData):
	var base_dir := enemy_data.get_path().get_base_dir()
	
	var skill_path := base_dir + "/skills"
	init_pools_from_dir(skill_path, [], "Skill")
