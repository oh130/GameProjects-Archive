extends Node

const STARTING_GOLD := 100

# node instances.
var run : Run

# save datas.
var save_data : SaveData

var player_datas : Array[PlayerData]

func start_game():
	if SaveData.check_data():
		load_game()
		run.load_run()
	else:
		init_game()
		run.load_run()

func init_game():
	save_data = SaveData.new()
	
	Random.set_random()
	SubRandom.set_random()
	
	save_data.gold = STARTING_GOLD
	run.gold = STARTING_GOLD
	
	save_data.player_datas = player_datas
	
	save_game()

func load_game():
	save_data = SaveData.load_data()
	Random.set_random_from_save(save_data.game_seed, save_data.state)
	SubRandom.set_random_from_save(save_data.combat_seed, save_data.combat_state)
	run.gold = save_data.gold
	player_datas = save_data.player_datas

func save_game():
	save_data.game_seed = Random.inst.seed
	save_data.state = Random.inst.state
	save_data.combat_seed = SubRandom.rand.seed
	save_data.combat_state = SubRandom.rand.state
	
	save_data.gold = run.gold
	
	save_data.save_data()

func game_over():
	SaveData.delete_data()
