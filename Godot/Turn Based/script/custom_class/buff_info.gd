class_name BuffInfo extends Node

var type : int
var amount : int
var duration : int
var is_fixed_val : bool
var is_buff : bool

func _init(_type : int, _amount : int, _duration : int, _is_fixed_val : bool):
	type = _type
	amount = _amount
	duration = _duration
	is_fixed_val = _is_fixed_val
	is_buff = (amount > 0)
