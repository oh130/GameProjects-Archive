class_name StatusUI extends Control

@onready var icon: TextureRect = %Icon
@onready var label: Label = %Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var count := 0 : set = set_count

func _ready():
	hide()

func set_count(value : int):
	if count == value:
		return
	
	if count < value:
		if count == 0:
			animation_player.play("appear")
		else:
			animation_player.play("add")
	
	count = value
	label.text = str(count)
	label.visible = count > 1
	
	if count <= 0:
		animation_player.play("disappear")
