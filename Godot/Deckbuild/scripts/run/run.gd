class_name Run extends Node

@onready var data_manager: DataManager = %DataManager
@onready var player: Player = %Player
@onready var board: Board = %Board
@onready var rewards: Rewards = %Rewards
@onready var game_over_ui: Control = %GameOverUI
@onready var enemy_pos: Node2D = %EnemyPos

func _ready():
	player.died.connect(game_over)
	board.game_over.connect(game_over)

func create_enemy():
	if not is_node_ready():
		await ready
	
	var enemy_data := Pool.enemy_pool[Random.get_randi(Pool.enemy_pool.size())]
	var enemy_inst := enemy_data.enemy_scene.instantiate()
	enemy_pos.add_child(enemy_inst)
	enemy_inst.data = enemy_data
	
	GameManager.enemy = enemy_inst
	GameManager.on_combat = true
	
	enemy_inst.died.connect(get_rewards)

func get_rewards():
	GameManager.on_combat = false
	
	rewards.show_rewards()

func game_over():
	GameManager.on_combat = false
	
	SaveData.delete_data()
	game_over_ui.show()
