extends Node2D

@onready var main = get_parent()

@onready var cell_container = $CellContainer
@onready var devil = $Objects/Devil
@onready var exit = $Objects/Exit
@onready var enemy_container = $Objects/EnemyContainer
@onready var statue_container = $Objects/StatueContainer
@onready var halo_container = $Objects/HaloContainer
@onready var stage_info = $UI/StageInfo

@export var cell_obj_checker : Array[Array]

const save_path = "user://progress.cfg"
var config = ConfigFile.new()

var cur_chap : int
var cur_level : int

signal stage_start()
signal send_stage_info(_chap : int, _level : int)

func _save():
	config.save(save_path)

func _load():
	if config.load(save_path) != OK:
		_save()
		return

func init_level(chap_idx : int, lv_idx : int):
	cell_obj_checker.resize(8)
	for i in 8:
		cell_obj_checker[i].resize(8)
	
	cur_chap = chap_idx
	cur_level = lv_idx
	
	stage_info.text = "STAGE " + str(cur_chap) + " - " + str(cur_level) 
	
	level_start()

func go_to_next_level():
	await Global.fade_out()
	
	cur_level += 1
	if cur_level > Level.level_info[str(cur_chap)].size():
		cur_chap += 1
		cur_level = 1
	
	stage_info.text = "STAGE " + str(cur_chap) + " - " + str(cur_level)
	
	level_start()

func push_pause_button():
	main.pause_game()

func level_start():
	init_cell_obj_checker()
	emit_signal("send_stage_info", cur_chap, cur_level)
	emit_signal("stage_start")
	
	Global.fade_in()

func init_cell_obj_checker():
	for i in 8:
		for j in 8:
			cell_obj_checker[i][j] = null

func _input(event):
	if event is InputEventKey and event.pressed and Global.input_available:
		if event.keycode == KEY_R:
			restart_command()

func restart_command():
	await Global.fade_out()
	
	level_start()

func devil_killed():
	await get_tree().create_timer(1).timeout
	restart_command()
