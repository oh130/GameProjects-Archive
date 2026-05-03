class_name DebugTool extends Control

const ITEM_UI_SCENE := preload("res://scenes/run/item/item_ui.tscn")

@onready var uncommon_items: GridContainer = %UncommonItems
@onready var rare_items: GridContainer = %RareItems

@onready var get_common_eq_button: Button = %GetCommonEqButton
@onready var level_up_button: Button = %LevelUpButton
@onready var time_scale_button: Button = %TimeScaleButton

func _ready():
	hide()
	
	get_common_eq_button.pressed.connect(rand_common_equip)
	level_up_button.pressed.connect(focused_player_get_exp)
	time_scale_button.pressed.connect(handle_time_scale)
	
	for item : Equipment in Pool.uncommon_eq_pool:
		var item_ui : ItemUI = ITEM_UI_SCENE.instantiate()
		uncommon_items.add_child(item_ui)
		item_ui.loc = ItemUI.Location.REWARD
		item_ui.get_reward_signal.connect(equip)
		item_ui.data = item
	
	for item : Equipment in Pool.rare_eq_pool:
		var item_ui : ItemUI = ITEM_UI_SCENE.instantiate()
		rare_items.add_child(item_ui)
		item_ui.loc = ItemUI.Location.REWARD
		item_ui.get_reward_signal.connect(equip)
		item_ui.data = item

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_tool"):
		if not visible:
			show()
		else:
			hide()

func rand_common_equip():
	equip(Pool.get_common_eq())

func equip(data : Equipment):
	DataManager.run.equip_equipment(data)
	
func focused_player_get_exp():
	DataManager.run.focused_player.get_exp(200)

func handle_time_scale():
	Engine.time_scale = 0.1 if Engine.time_scale == 1 else 1
