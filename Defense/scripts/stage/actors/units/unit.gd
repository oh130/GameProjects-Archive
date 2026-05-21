class_name Unit extends Actor

@onready var remain_factor: Sprite2D = %RemainFactor

var data : UnitData

var is_move_remain := true :
	set(value):
		is_move_remain = value
		check_act_remain()

var is_attack_remain := true :
	set(value):
		is_attack_remain = value
		check_act_remain()

func _ready():
	super._ready()
	sprite_2d.material.set("shader_parameter/color", UNIT_OUTLINE_COLOR)
	
	EventBus.player_turn.connect(on_start_turn)
	EventBus.enemy_turn.connect(on_end_turn)
	
	remain_factor.hide()

func after_appear():
	super.after_appear()
	
	check_act_remain()

func on_start_turn():
	is_move_remain = true
	is_attack_remain = true

func on_end_turn():
	selected = false
	remain_factor.hide()

func check_act_remain():
	if is_attack_remain or is_move_remain:
		remain_factor.show()
	else:
		remain_factor.hide()

func move_command(coord : Vector2i):
	is_move_remain = false
	cur_coord = coord
	animation_player.play("move")

func move_to():
	position = GameManager.ground.map_to_local(cur_coord)

func attack_command(coord : Vector2i):
	is_attack_remain = false
	animation_player.play("attack")
	GameManager.ground.attack_enemy(coord, data.damage, data.armor_penetration)
