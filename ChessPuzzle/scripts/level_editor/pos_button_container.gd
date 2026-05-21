extends GridContainer

@export var selected_piece_type : int

var pos_button_scene : PackedScene = preload("res://scenes/editor_instances/pos_button.tscn")

func _ready():
	for i in 64:
		var button = pos_button_scene.instantiate()
		add_child(button)
		button.pressed.connect(hide_pos_buttons)
		button.init_coord(Vector2i(i % 8, i / 8))

func show_pos_buttons():
	var cnt : int = 0
	for child in get_children():
		child.active_self()

func hide_pos_buttons():
	for child in get_children():
		if not child.enemy_exist:
			child.inactive_self()

func clear_pos_buttons():
	for child in get_children():
		child.inactive_self()
