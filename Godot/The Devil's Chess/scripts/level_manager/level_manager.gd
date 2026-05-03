extends Node2D

@onready var main = $".."
@onready var level_container = $LevelContainer

var chap_idx : int

signal level_selected(_chap_idx : int, _lv_idx : int)

func select_chapter(_chap_idx : int):
	chap_idx = _chap_idx
	level_container.init_level_buttons(chap_idx)

func select_level(_lv_idx : int):
	await Global.fade_out()
	
	main.inactive_level_manager()
	main.active_table()
	emit_signal("level_selected", chap_idx, _lv_idx)

func back_to_main_menu():
	await Global.fade_out()
	main.inactive_level_manager()
	main.active_main_menu()
	Global.fade_in()
