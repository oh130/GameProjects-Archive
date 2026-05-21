class_name Structure extends Actor

@export var data : ArmamentData

func _ready():
	super._ready()
	sprite_2d.material.set("shader_parameter/color", UNIT_OUTLINE_COLOR)
	
	EventBus.player_turn.connect(on_start_turn)
	EventBus.enemy_turn.connect(on_end_turn)

func on_start_turn():
	pass

func on_end_turn():
	pass
