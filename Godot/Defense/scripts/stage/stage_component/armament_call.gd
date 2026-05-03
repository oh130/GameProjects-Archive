class_name ArmamentCall extends Button

@onready var ink: HBoxContainer = %Ink
@onready var tile: HBoxContainer = %Tile
@onready var ink_cost: Label = %InkCost
@onready var tile_cost: Label = %TileCost

var data : ArmamentData : set = set_data

func set_data(armament_data : ArmamentData):
	data = armament_data
	
	if not is_node_ready():
		await ready
	
	icon = data.sprite
	
	if data.ink_cost > 0:
		ink_cost.text = str(data.ink_cost)
		ink.show()
	else:
		ink.hide()
	
	if data is UnitData:
		tile_cost.text = str(data.tile_cost)
		tile.show()
	else:
		tile.hide()
	
	if data is WeaponData:
		pass

func check_callable():
	if not is_node_ready():
		await ready
		
	disabled = GameManager.ground.base_tier < data.tier\
		or GameManager.ground.ink < data.ink_cost
	
	if data is UnitData:
		disabled = GameManager.ground.unused_count < data.tile_cost

func after_call():
	pass
