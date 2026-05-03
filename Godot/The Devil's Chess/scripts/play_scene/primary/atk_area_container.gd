extends Node2D

@onready var table = $".."
@onready var enemy_container = $"../Objects/EnemyContainer"

var atk_area_scene : PackedScene = preload("res://scenes/instances/atk_area.tscn")

var is_atk_area_valid : Array[Array]
var atk_area_highlights : Array[Array]
var always_show : bool

func _ready():
	atk_area_highlights.resize(8)
	is_atk_area_valid.resize(8)
	for i in 8:
		atk_area_highlights[i].resize(8)
		is_atk_area_valid[i].resize(8)
		for j in 8:
			var area = atk_area_scene.instantiate()
			add_child(area)
			area.position = Global.get_pos_by_coord(Vector2i(j,i))
			atk_area_highlights[i][j] = area
			is_atk_area_valid[i][j] = false
			area.hide()

func check_atk_areas():
	for i in 8:
		for j in 8:
			is_atk_area_valid[i][j] = false
	
	for enemy : Enemy in enemy_container.get_children():
		var coord_arr : Array[Vector2i] = Global.enemy_piece_atk_coords(enemy.coord, enemy.piece_type, table.cell_obj_checker)
		for coord in coord_arr:
			is_atk_area_valid[coord.y][coord.x] = true

func show_atk_area_of_enemy(enemy : Enemy):
	if always_show:
		return
	
	hide_atk_area_all()
	
	var coord_arr : Array[Vector2i] = Global.enemy_piece_atk_coords(enemy.coord, enemy.piece_type, table.cell_obj_checker)
	for coord in coord_arr:
		atk_area_highlights[coord.y][coord.x].show()

func show_atk_area_all():
	for i in 8:
		for j in 8:
			if is_atk_area_valid[i][j]:
				atk_area_highlights[i][j].show()

func hide_atk_area_all():
	for arr in atk_area_highlights:
		for area in arr:
			area.hide()

func on_enemy_mouse_exit():
	if not always_show:
		hide_atk_area_all()

func update_atk_area():
	hide_atk_area_all()
	check_atk_areas()
	
	if always_show:
		show_atk_area_all()

func always_show_checked(_show : bool):
	always_show = _show
	update_atk_area()
