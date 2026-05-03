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
	return inst.randi() % ran

func get_randf() -> float:
	return inst.randf()

func get_rand_moded_integer(base : int) -> int:
	return base + (inst.randi() % RAND_INT_MOD)
