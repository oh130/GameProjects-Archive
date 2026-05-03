extends HBoxContainer

@onready var level_manager = $".."

var chapter_button_scene : PackedScene = preload("res://scenes/instances/chapter_button.tscn")

func _ready():
	init_chapter_buttons()

func init_chapter_buttons():
	for i in Level.level_info.size():
		var chapter_button = chapter_button_scene.instantiate()
		add_child(chapter_button)
		chapter_button.text = str(i+1)
		chapter_button.pressed.connect(level_manager.select_chapter.bind(i+1))
