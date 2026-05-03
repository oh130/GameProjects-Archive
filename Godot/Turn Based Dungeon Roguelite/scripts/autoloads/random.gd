extends Node
# decide the flow of run by seed.
# actually, it is not random. it is considered by seed.
# all of player's behavior cannot affect it's state.
# in same seed, same route, must have same result.

const RAND_INT_MOD := 20

var inst : RandomNumberGenerator

func set_random():
	inst = RandomNumberGenerator.new()
	inst.randomize()

func set_random_from_save(game_seed : int, state : int):
	inst = RandomNumberGenerator.new()
	inst.seed = game_seed
	inst.state = state

func get_randi(ran : int) -> int:
	if ran == 0:
		return 0
	
	return inst.randi() % ran

func get_randi_range(from : int, to : int) -> int:
	return inst.randi_range(from, to)

func get_randf() -> float:
	return inst.randf()

func get_rand_moded_integer(base : int) -> int:
	return base + (inst.randi() % RAND_INT_MOD)

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
