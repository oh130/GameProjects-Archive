extends Node

@onready var table = $"../.."
@onready var devil = $"../Devil"
@onready var atk_area_container = $"../../AtkAreaContainer"

var statue_scene : PackedScene = preload("res://scenes/instances/statue.tscn")

func create_statues(cur_chap : int, cur_level : int):
	var statue_infoes : Array = Level.level_info[str(cur_chap)][str(cur_level)]["statues"]
	
	for child in get_children():
		remove_child(child)
	
	for info in statue_infoes:
		var statue : Statue = statue_scene.instantiate()
		add_child(statue)
		statue.init_statue(info)

func devil_move_ended(_coord : Vector2i):
	if atk_area_container.is_atk_area_valid[_coord.y][_coord.x]:
		for statue : Statue in get_children():
			var attackable_coords : Array[Vector2i] = Global.enemy_piece_atk_coords(statue.coord, statue.piece_type, table.cell_obj_checker)
			if _coord in attackable_coords:
				statue.kill_devil(_coord)
