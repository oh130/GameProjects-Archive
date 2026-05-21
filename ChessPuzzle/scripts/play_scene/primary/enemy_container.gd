extends Node

@onready var table = $"../.."
@onready var devil = $"../Devil"
@onready var atk_area_container = $"../../AtkAreaContainer"

var enemy_scene : PackedScene = preload("res://scenes/instances/enemy.tscn")

func create_enemies(cur_chap : int, cur_level : int):
	var enemy_infoes : Array = Level.level_info[str(cur_chap)][str(cur_level)]["enemies"]
	
	for child in get_children():
		remove_child(child)
	
	for info in enemy_infoes:
		var enemy : Enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.init_enemy(info)

func devil_move_ended(_coord : Vector2i):
	for enemy : Enemy in get_children():
		if enemy.coord == _coord:
			remove_child(enemy)
	
	atk_area_container.update_atk_area()
	
	if atk_area_container.is_atk_area_valid[_coord.y][_coord.x]:
		for enemy : Enemy in get_children():
			var attackable_coords : Array[Vector2i] = Global.enemy_piece_atk_coords(enemy.coord, enemy.piece_type, table.cell_obj_checker)
			if _coord in attackable_coords:
				enemy.kill_devil(_coord)
