class_name EnhancementSelect extends CanvasLayer

const ENHANCEMENT_UI_SCENE := preload("res://scenes/run/enhancement/enhancement_ui.tscn")
const RAND_SELECT_AMOUNT := 4

@onready var enhancement_container: GridContainer = %EnhancementContainer
@onready var reroll_button: Button = %RerollButton

var player_data : PlayerData

func _ready() -> void:
	reroll_button.pressed.connect(reroll)
	hide()

func show_enhancements():
	player_data = DataManager.run.focused_player.data
	player_data.enhancement_reroll_chance += 1
	reroll_button.disabled = false
	reroll_button.text = "Reroll (%d)" % player_data.enhancement_reroll_chance
	
	get_and_show_rand_enhancements()
	
	if enhancement_container.get_child_count() == 0:
		DataManager.run.give_enhancement_to_player(null)
		return
	
	show()

func get_and_show_rand_enhancements():
	for child in enhancement_container.get_children():
		enhancement_container.remove_child(child)
	
	var select_pool : Array[Enhancement] = []
	var show_arr : Array[Enhancement] = []
	
	for enh : Enhancement in player_data.enhancements:
		if not enh.selected:
			select_pool.append(enh)
	
	for i in RAND_SELECT_AMOUNT:
		if select_pool.is_empty():
			break
		
		var show_e : Enhancement = Random.pick_random(select_pool)
		select_pool.erase(show_e)
		show_arr.append(show_e)
	
	for enh : Enhancement in show_arr:
		var enhancement_ui := ENHANCEMENT_UI_SCENE.instantiate()
		enhancement_container.add_child(enhancement_ui)
		enhancement_ui.data = enh
		enhancement_ui.enhancement_clicked.connect(enhancement_selected)

func enhancement_selected(data : Enhancement):
	DataManager.run.give_enhancement_to_player(data)
	hide()

func reroll():
	player_data.enhancement_reroll_chance -= 1
	reroll_button.text = "Reroll (%d)" % player_data.enhancement_reroll_chance
	reroll_button.disabled = (player_data.enhancement_reroll_chance == 0)
	get_and_show_rand_enhancements()
