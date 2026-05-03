extends Node2D

@onready var positions = $Positions.get_children()
@onready var enemies_node = $Enemies

func create_enemies():
	for i in positions.size():
		var rand_i = randi_range(0, GlobalData.enemy_unit_names.size() - 1)
		var new_unit : StatusController = GlobalData.unit_scene.instantiate()
		new_unit.unit_created(GlobalData.enemy_unit_names[rand_i], i, true)
		enemies_node.add_child(new_unit)
	
	set_pos()

func set_pos():
	for enemy in enemies_node.get_children():
		enemy.position = positions[enemy.combat_pos].position
