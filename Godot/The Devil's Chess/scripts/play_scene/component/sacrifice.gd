class_name Sacrifice extends Button

@onready var cost_text = $Cost

@export var sac_type : Global.SAC_TYPE
@export var cost : int

func _ready():
	icon = Global.sacrifice_textures[sac_type]
	cost_text.text = str(cost)
	set_disable()

func set_able():
	disabled = false

func set_disable():
	disabled = true
