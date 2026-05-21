class_name TurnManager extends Node

@onready var ground: Ground = %Ground
@onready var enemies: Node2D = %Enemies
@onready var turn_button: Button = %TurnButton

var stage_data : StageData

var turn_count := 0 : set = set_turn_count
var spawn_tier := 0

var enemy_action_queue : Array[Enemy]

func _ready():
	stage_data = GameManager.stage_data

func set_turn_count(value : int):
	turn_count = value
	
	if spawn_tier < stage_data.tier_up_turn.size()\
	and turn_count == stage_data.tier_up_turn[spawn_tier]:
		spawn_tier += 1

# player turn.
func turn_start():
	turn_count += 1
	random_spawning()
	
	turn_button.disabled = false
	EventBus.player_turn.emit()

# enemy turn.
func turn_end():
	turn_button.disabled = true
	EventBus.enemy_turn.emit()
	
	enemy_sequential_action()

func random_spawning():
	var spawnable_enemies := stage_data.stage_enemies.filter(
		func(data : EnemyData):
			return data.tier <= spawn_tier
	)
	
	var spawn_coord : Vector2i
	if randi() % 2:
		spawn_coord = Vector2i(Ground.MAP_WIDTH, randi() % (Ground.MAP_WIDTH + 1))
	else:
		spawn_coord = Vector2i(randi() % (Ground.MAP_WIDTH + 1), Ground.MAP_WIDTH)
	
	if randi() % 2:
		spawn_coord.x *= -1
	if randi() % 2:
		spawn_coord.y *= -1
	
	spawn_enemy(spawn_coord, spawnable_enemies[randi() % spawnable_enemies.size()])

func spawn_enemy(coord : Vector2i, enemy_data : EnemyData):
	var enemy : Enemy = enemy_data.enemy.instantiate()
	enemy.data = enemy_data
	enemy.position = ground.map_to_local(coord)
	enemy.cur_coord = coord
	
	enemy.died.connect(ground.erase_enemy)
	
	enemies.add_child(enemy)
	enemy_action_queue.append(enemy)
	ground.add_enemy(enemy)

func enemy_sequential_action():
	for enemy in enemy_action_queue:
		enemy.selected = true
		
		if move_checker(enemy):
			enemy.move_command(Vector2(4,4))
			ground.move_enemy(enemy, Vector2(4,4))
			await enemy.act_ended
		
		if attack_checker(enemy):
			enemy.attack_command(Vector2(1,1))
			await enemy.act_ended
		
		enemy.selected = false
	
	turn_start()

func enemy_find_target_tile(enemy : Enemy):
	pass

func move_checker(enemy : Enemy) -> bool:
	var movable_tiles :=\
	ground.get_surrounding_tiles(enemy.cur_coord, enemy.data.mobility).filter(
		func(coord : Vector2i):
			return not ground.actor_existing_tiles.has(coord)
	)
	
	return true

func attack_checker(enemy : Enemy) -> bool:
	var attackable_tiles :=\
	ground.get_straight_tiles(enemy.cur_coord, enemy.data.reach).filter(
		func(coord : Vector2i):
			return ground.current_painted_tiles.has(coord)
	)
	
	return true
