class_name Reward extends CanvasLayer

const COMBAT_BASE_GOLD = 20

@onready var reward_container: Control = %RewardContainer
@onready var inventory: Inventory = %Inventory



var reward_items : Array[ItemUI]
var more_equipment := false

func _ready():
	for child : ItemUI in reward_container.get_children():
		reward_items.append(child)
		child.loc = ItemUI.Location.REWARD
		child.get_reward_signal.connect(reward_selected)
	
	hide()

func get_consumable():
	inventory.add_item_to_inventory(Random.pick_random(Pool.consumable_pool))

func get_equipments():
	var selected_eqs : Array[Equipment]
	for item_ui : ItemUI in reward_items:
		var rand_f := Random.get_randf()
		var equipment : Equipment
		if rand_f < 0.6:
			equipment = Pool.get_common_eq()
			while selected_eqs.has(equipment):
				equipment = Pool.get_common_eq()
		elif rand_f < 0.9:
			equipment = Random.pick_random(Pool.uncommon_eq_pool)
			while selected_eqs.has(equipment):
				equipment = Random.pick_random(Pool.uncommon_eq_pool)
		else:
			equipment = Random.pick_random(Pool.rare_eq_pool)
			while selected_eqs.has(equipment):
				equipment = Random.pick_random(Pool.rare_eq_pool)
		
		selected_eqs.append(equipment)
		item_ui.data = equipment
		item_ui.show()
	
	show()
	GameManager.show_tween(reward_container)

func get_combat_rewards():
	var combat_gold := Random.get_rand_moded_integer(COMBAT_BASE_GOLD)
	
	match DataManager.save_data.current_route:
		Enum.Route.ENEMY_MORE_GOLD:
			combat_gold *= 2
		Enum.Route.ENEMY_MORE_EQUIPMENT:
			more_equipment = true
		Enum.Route.ELITE:
			pass
		Enum.Route.BOSS:
			pass
	
	DataManager.run.gold += combat_gold
	get_consumable()
	get_equipments()

func reward_selected(item : Item):
	DataManager.run.equip_equipment(item)
	if more_equipment:
		more_equipment = false
		get_equipments()
		return
	
	DataManager.run.show_route_choice()
	hide()
