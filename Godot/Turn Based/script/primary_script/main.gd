extends Node

@onready var main_menu = $MainMenu
@onready var setting = $Setting

@export var tavern_scene : PackedScene

func _ready():
	setting.process_mode = Node.PROCESS_MODE_DISABLED
	setting.hide()

func on_start_pressed():
	main_menu.process_mode = Node.PROCESS_MODE_DISABLED
	main_menu.hide()
	
	var tavern = tavern_scene.instantiate()
	add_child(tavern)
