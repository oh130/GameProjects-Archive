extends GridContainer

@onready var sacrifice_container = $"../../SacrificeContainer"

var sacrifice_generator_scene : PackedScene = preload("res://scenes/editor_instances/sacrifice_generator.tscn")

func _ready():
	for i in Global.SAC_TYPE.size():
		var generator = sacrifice_generator_scene.instantiate()
		add_child(generator)
		generator.init_generator(i)
		generator.pressed.connect(generator_pressed.bind(i))

func generator_pressed(sac_type : int):
	sacrifice_container.get_child(sac_type).add_sacrifice()

func refresh_all_generator():
	for child in get_children():
		child.count = 0
		child.count_text.text = str(0)
