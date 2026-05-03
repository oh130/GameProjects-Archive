extends Node

const COMMON_EQ := preload("res://resources/items/equipments/common.tres")
const COMMON_EQ_NAME := "FRAGMENT"
const SUB_STAT_IS_TAKE_DMG_AMP_CHANCE := 0.4
const EQUIPMENT_TWIST_STANDARD : Dictionary[Enum.Stat, float] =\
{
	Enum.Stat.MAX_HEALTH : 3,
	Enum.Stat.MAX_ENERGY : 1,
	Enum.Stat.STRENGTH : 2,
	Enum.Stat.INTELLIGENCE : 2,
	Enum.Stat.DEXTERITY : 2,
	Enum.Stat.FAITH : 2,
	Enum.Stat.CRIT : 0.5,
	Enum.Stat.CRIT_MUL : 1,
	Enum.Stat.ARMOR : 2,
	Enum.Stat.DODGE : 0.5,
	Enum.Stat.ARMOR_PEN : 2,
	Enum.Stat.ARMOR_PEN_RATE : 0.5,
	
	Enum.Stat.RESILIENCE : 2,
	Enum.Stat.ADD_ENERGY_REG : 0.5,
	Enum.Stat.COUNTER_CHANCE : 1,
	Enum.Stat.ASSIST_CHANCE : 1,
	
	Enum.Stat.IMPACT_AMP : 1,
	Enum.Stat.SLASH_AMP : 1,
	Enum.Stat.PIERCE_AMP : 1,
	Enum.Stat.NATURE_AMP : 1,
	Enum.Stat.ARCANE_AMP : 1,
	Enum.Stat.MYSTIC_AMP : 1,
	Enum.Stat.ENERGY_DMG_AMP : 1,
	Enum.Stat.COUNTER_DMG_AMP : 1,
	Enum.Stat.ASSIST_DMG_AMP : 1,
	
	Enum.Stat.TAKE_DMG_AMP : -0.5,
}

const res : PoolRes = preload("res://resources/common_data/pool_res.tres")

var player_pool : Array[PlayerData]
var uncommon_eq_pool : Array[Equipment]
var rare_eq_pool : Array[Equipment]
var consumable_pool : Array[Consumable]

var chapter_pool : Array[Chapter]
var encounter_pool : Array[EncounterData]
var enemy_group_pool : Array[EnemyGroup]
var elite_group_pool : Array[EnemyGroup]
var boss_group_pool : Array[EnemyGroup]

func _init() -> void:
	player_pool.assign(res.player_pool)
	uncommon_eq_pool.assign(res.uncommon_eq_pool)
	rare_eq_pool.assign(res.rare_eq_pool)
	consumable_pool.assign(res.consumable_pool)
	chapter_pool.assign(res.chapter_pool)
	encounter_pool.assign(res.encounter_pool)
	enemy_group_pool.assign(res.enemy_group_pool)
	elite_group_pool.assign(res.elite_group_pool)
	boss_group_pool.assign(res.boss_group_pool)

func check_equipment(equipment : Equipment) -> bool:
	if equipment.is_unique:
		for player in DataManager.player_datas:
			if player.equipments.has(equipment):
				return false
	
	return true

func get_common_eq() -> Equipment:
	var ret := COMMON_EQ.duplicate()
	ret.resource_name = COMMON_EQ_NAME
	
	### result ###
	var total_stat_arr : Dictionary[int, float]
	for key in EQUIPMENT_TWIST_STANDARD.keys():
		total_stat_arr[key] = 0
	##############
	
	var def_amount := 3
	while def_amount > 0:
		var rand_amount := 1 + Random.get_randi(def_amount - 1)
		def_amount -= rand_amount
		
		var rand_stat : Enum.Stat = Random.pick_random(EQUIPMENT_TWIST_STANDARD.keys())
		while rand_stat == Enum.Stat.TAKE_DMG_AMP:
			rand_stat = Random.pick_random(EQUIPMENT_TWIST_STANDARD.keys())
		
		total_stat_arr[rand_stat] += EQUIPMENT_TWIST_STANDARD[rand_stat] * rand_amount
	
	# twist equipment.
	var twist_amount := Random.get_randi(DataManager.save_data.cleared_chapters.size() + 2)
	while twist_amount > 0:
		var rand_amount := 1 + Random.get_randi(twist_amount - 1)
		twist_amount -= rand_amount
		
		var add_stat : Enum.Stat = Random.pick_random(EQUIPMENT_TWIST_STANDARD.keys())
		var sub_stat : Enum.Stat = Random.pick_random(EQUIPMENT_TWIST_STANDARD.keys())
		
		# handle add stat - take dmg amp is only in sub stat.
		while add_stat == Enum.Stat.TAKE_DMG_AMP:
			add_stat = Random.pick_random(EQUIPMENT_TWIST_STANDARD.keys())
		
		# handle sub stat.
		if Random.get_randf() < SUB_STAT_IS_TAKE_DMG_AMP_CHANCE:
			sub_stat = Enum.Stat.TAKE_DMG_AMP
		else:
			while sub_stat == Enum.Stat.TAKE_DMG_AMP\
			or total_stat_arr[sub_stat] > 0 or (sub_stat == add_stat):
				sub_stat = Random.pick_random(EQUIPMENT_TWIST_STANDARD.keys())
		
		total_stat_arr[add_stat] += EQUIPMENT_TWIST_STANDARD[add_stat] * rand_amount
		total_stat_arr[sub_stat] -= EQUIPMENT_TWIST_STANDARD[sub_stat] * rand_amount
	
	for key in total_stat_arr:
		if total_stat_arr[key] == 0:
			continue
		
		if ret.stats.has(key):
			ret.stats[key].amount += total_stat_arr[key]
		else:
			var new_amount := Amount.new()
			new_amount.amount = total_stat_arr[key]
			ret.stats[key] = new_amount
	
	return ret

func get_id(val : Resource) -> String:
	var clean_name := val.get_path().get_file().get_basename()
	var pos := clean_name.find("_")
	if pos != -1 and clean_name[pos - 1].is_valid_int():
		clean_name = clean_name.substr(pos + 1)
	
	return clean_name.to_upper()
