extends Node2D

@onready var main_menu = $MainMenu
@onready var table = $Table
@onready var level_manager = $LevelManager
@onready var pause = $UI/Pause
@onready var settings = $UI/Settings
@onready var warning = $UI/Warning

var cur_scene : int
var cur_exit_type : int

func _ready():
	inactive_table()
	inactive_level_manager()
	inactive_level_editor()
	active_main_menu()
	pause.hide()
	settings.hide()
	warning.hide()

func active_main_menu():
	main_menu.show()
	cur_scene = Global.SCENE_TYPE.MAIN_MENU

func inactive_main_menu():
	main_menu.hide()

func active_table():
	table.process_mode = Node.PROCESS_MODE_PAUSABLE
	table.get_node("UI").show()
	table.show()
	cur_scene = Global.SCENE_TYPE.TABLE

func inactive_table():
	table.hide()
	table.get_node("UI").hide()
	table.process_mode = Node.PROCESS_MODE_DISABLED

func active_level_manager():
	level_manager.show()
	cur_scene = Global.SCENE_TYPE.LEVEL_MANAGER

func inactive_level_manager():
	level_manager.hide()

func active_level_editor():
	#level_editor.process_mode = Node.PROCESS_MODE_PAUSABLE
	#level_editor.get_node("UI").show()
	#level_editor.show()
	#cur_scene = Global.SCENE_TYPE.LEVEL_EDITOR
	pass

func inactive_level_editor():
	#level_editor.hide()
	#level_editor.get_node("UI").hide()
	#level_editor.process_mode = Node.PROCESS_MODE_DISABLED
	pass

func _input(event):
	if event is InputEventKey and event.pressed and Global.input_available:
		if cur_scene == Global.SCENE_TYPE.TABLE and event.keycode == KEY_ESCAPE:
			if get_tree().paused:
				resume_game()
			else:
				pause_game()

func pause_game():
	pause.show()
	get_tree().paused = true

func resume_game():
	get_tree().paused = false
	pause.hide()

func open_setting():
	settings.show()

func close_setting():
	settings.hide()

func exit_to_main_menu():
	warning.show()
	cur_exit_type = 0

func exit_to_level_manager():
	warning.show()
	cur_exit_type = 1

func exit_to_desktop():
	warning.show()
	cur_exit_type = 2

func accept_exit():
	warning.hide()
	resume_game()
	
	if cur_exit_type == 2:
		get_tree().quit()
	
	await Global.fade_out()
	inactive_table()
	
	if cur_exit_type == 0:
		active_main_menu()
	else:
		active_level_manager()
	
	Global.fade_in()

func exit_cancel():
	warning.hide()
