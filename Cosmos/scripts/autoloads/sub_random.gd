extends Node

var rand : RandomNumberGenerator

func set_random():
	rand = RandomNumberGenerator.new()
	rand.randomize()

func set_random_from_save(game_seed : int, state : int):
	rand = RandomNumberGenerator.new()
	rand.seed = game_seed
	rand.state = state

func get_randi(ran : int) -> int:
	return rand.randi() % ran

func get_randf_range(from : float, to : float) -> float:
	return rand.randf_range(from, to)

func get_rand_figured_value() -> float:
	return 0.9 + rand.randi_range(0, 20) * 0.01

func roll_chance(percent : float) -> bool:
	return 0.01 * percent > rand.randf()

func pick_random(array : Array) -> Variant:
	return array[get_randi(array.size())]

func array_shuffle(array: Array) -> void:
	if array.size() < 2:
		return

	for i in range(array.size()-1, 0, -1):
		var j := get_randi(i+1)
		var tmp = array[j]
		array[j] = array[i]
		array[i] = tmp
