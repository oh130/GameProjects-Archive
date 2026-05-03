class_name Shop extends CanvasLayer

const BASE_REFUND_MUL := 0.5
const EQUIPMENT_PRICE_BY_RARITY := [30, 70, 150]
const CONSUMABLE_PRICE := 20

@onready var shop_structure: TextureButton = %ShopStructure
@onready var shop_inside: Panel = %ShopInside
@onready var exit_button: Button = %ExitButton

@onready var equipment_container: Control = %EquipmentContainer
@onready var consumable_container: Control = %ConsumableContainer

var shop_opened : bool

func _ready():
	shop_structure.pressed.connect(
		func():
			shop_structure.disabled = true
			shop_inside.visible = true
			shop_opened = true
	)
	exit_button.pressed.connect(
		func():
			shop_inside.visible = false
			shop_opened = false
			DataManager.run.show_route_choice()
	)
	
	shop_inside.hide()
	hide()

func enter_shop():
	for p in DataManager.run.players:
		SituationManager.occur(Enum.Situation.SHOP_ENTER, p)
	
	shop_structure.disabled = false
	
	var chosen_equipments : Array[Equipment]
	for child : ShopItem in equipment_container.get_children():
		var rand_f := Random.get_randf()
		var rarity : int
		var equipment : Equipment
		if rand_f < 0.6:
			# common.
			rarity = 0
			equipment = Pool.get_common_eq()
			while not Pool.check_equipment(equipment) and equipment.is_unique and chosen_equipments.has(equipment):
				equipment = Pool.get_common_eq()
		elif rand_f < 0.9:
			# uncommon.
			rarity = 1
			equipment = Random.pick_random(Pool.uncommon_eq_pool)
			while not Pool.check_equipment(equipment) and equipment.is_unique and chosen_equipments.has(equipment):
				equipment = Random.pick_random(Pool.uncommon_eq_pool)
		else:
			# rare.
			rarity = 2
			equipment = Random.pick_random(Pool.rare_eq_pool)
			while not Pool.check_equipment(equipment) and equipment.is_unique and chosen_equipments.has(equipment):
				equipment = Random.pick_random(Pool.rare_eq_pool)
		
		child.data = equipment
		child.price = Random.get_rand_moded_integer(EQUIPMENT_PRICE_BY_RARITY[rarity])
		child.show()
	
	for child : ShopItem in consumable_container.get_children():
		var consumable : Consumable = Random.pick_random(Pool.consumable_pool)
		child.data = consumable
		child.price = Random.get_rand_moded_integer(CONSUMABLE_PRICE)
		child.show()
	
	show()
