extends GridContainer

@onready var pos_button_container = $"../../PosButtonContainer"

var enemy_generator_scene : PackedScene = preload("res://scenes/editor_instances/enemy_generator.tscn")

func _ready():
	for i in Global.PIECE_TYPE.size():
		var generator = enemy_generator_scene.instantiate()
		add_child(generator)
		generator.init_generator(i)
		generator.pressed.connect(enemy_generator_pressed.bind(i))

func enemy_generator_pressed(piece_type : int):
	pos_button_container.selected_piece_type = piece_type
	pos_button_container.show_pos_buttons()
