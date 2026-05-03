class_name MoveData extends Node

var cur_pos : int
var end_pos : int
var is_enemy : bool

func _init(_cur_pos : int, _end_pos : int, _is_enemy : bool):
	cur_pos = _cur_pos
	end_pos = _end_pos
	is_enemy = _is_enemy
