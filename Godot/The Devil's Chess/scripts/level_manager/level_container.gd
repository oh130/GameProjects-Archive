extends GridContainer

@onready var level_manager = $".."

var level_button_scene : PackedScene = preload("res://scenes/instances/level_button.tscn")

func init_level_buttons(_cur_chap : int):
	for child in get_children():
		remove_child(child)
	
	for i in Level.level_info[str(_cur_chap)].size():
		var level_button = level_button_scene.instantiate()
		add_child(level_button)
		level_button.text = str(i+1)
		level_button.pressed.connect(level_manager.select_level.bind(i+1))
