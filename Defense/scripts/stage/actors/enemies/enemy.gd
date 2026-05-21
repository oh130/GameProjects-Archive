class_name Enemy extends Actor

var data : EnemyData : set = set_data

var health : int

func _ready():
	super._ready()
	
	sprite_2d.material.set("shader_parameter/color", ENEMY_OUTLINE_COLOR)

func set_data(enemy_data : EnemyData):
	data = enemy_data
	
	if not is_node_ready():
		await ready
	
	health = data.max_health

func move_command(coord : Vector2i):
	cur_coord = coord
	animation_player.play("move")

func move_to():
	position = GameManager.ground.map_to_local(cur_coord)

func attack_command(coord : Vector2i):
	animation_player.play("attack")
	GameManager.ground.hit_tile(coord, data.damage)

func take_damage(amount : int, arm_pen : bool):
	if data.armored and not arm_pen:
		amount = int(0.5 * amount)
	
	health -= clampi(amount, 0, data.max_health)
	
	if health == 0:
		death()
