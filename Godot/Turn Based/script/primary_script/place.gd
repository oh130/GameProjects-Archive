extends Node2D

@onready var player_group = $PlayerGroup
@onready var enemy_group = $EnemyGroup
@onready var combat_manager = $CombatManager

func combat_start(player_units : Array[StatusController]):
	player_group.create_players(player_units)
	enemy_group.create_enemies()
	combat_manager.combat_confront()
