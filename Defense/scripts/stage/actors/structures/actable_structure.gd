class_name ActableStructure extends Structure

@onready var remain_factor: Sprite2D = %RemainFactor

var is_attack_remain := true :
	set(value):
		is_attack_remain = value
		check_act_remain()

func _ready():
	super._ready()
	
	remain_factor.hide()

func after_appear():
	super.after_appear()
	
	check_act_remain()

func on_start_turn():
	is_attack_remain = true

func on_end_turn():
	selected = false
	remain_factor.hide()

func check_act_remain():
	if is_attack_remain:
		remain_factor.show()
	else:
		remain_factor.hide()

func attack_command(coord : Vector2i):
	is_attack_remain = false
	animation_player.play("attack")
	GameManager.ground.attack_enemy(coord, data.damage, data.armor_penetration)
