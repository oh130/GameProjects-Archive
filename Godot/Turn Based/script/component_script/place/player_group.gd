extends Node2D

@onready var positions = $Positions.get_children()
@onready var players_node = $Players

func create_players(_player_units : Array[StatusController]):
	if players_node.get_child_count() > 0:
		return
	
	for player in _player_units:
		if player != null:
			players_node.add_child(player)
	
	set_pos()

func set_pos():
	for player in players_node.get_children():
		player.position = positions[player.combat_pos].position
