extends Control

@onready var base = $Base
@onready var count_text = $AddedCount

@export var sac_type : int
@export var count : int

func init_generator(_sac_type : int):
	sac_type = _sac_type
	base.texture = Global.sacrifice_textures[sac_type]

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			count += 1
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			count -= 1
		count_text.text = str(count)
