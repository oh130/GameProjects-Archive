class_name DataManager extends Node

const ITEM_SCENE := preload("res://scenes/run/item.tscn")

@onready var player: Player = %Player
@onready var board: Board = %Board
@onready var inventory: Control = %Inventory

@onready var game_progress_label: Label = %GameProgressLabel
@onready var game_time_label: Label = %GameTimeLabel

@export_group("Default Starting Variables")
@export var max_health : int
@export var deck : Array[ElementData]
@export var items : Array[ItemData]

var save_data : SaveData
var progress : int :
	set(value):
		progress = value
		game_progress_label.text = "Floor %d" % progress
var game_time : int :
	set(value):
		game_time = value
		game_time_label.text = "%02d : %02d" % [game_time / 60, game_time % 60]

signal create_next()

func _ready():
	GameManager.data_manager = self
	EventBus.reward_selected.connect(run_proceed)
	
	if SaveData.check_data():
		load_game()
	else:
		init_game()

func init_game():
	save_data = SaveData.new()
	
	Random.set_random()
	player.max_health = max_health
	player.health = max_health
	await board.init_board()
	
	run_proceed()

func load_game():
	save_data = SaveData.load_data()
	
	Random.set_random_from_save(save_data.game_seed, save_data.state)
	
	progress = save_data.progress
	game_time = save_data.game_time
	
	player.max_health = save_data.max_health
	player.health = save_data.health
	board.load_board(save_data.board_state)
	deck = save_data.deck
	items = save_data.items
	
	# inventory.
	for item in items:
		add_item_to_inventory(item)
	
	run_proceed()

func save_game():
	save_data.game_seed = Random.inst.seed
	save_data.state = Random.inst.state
	
	save_data.progress = progress
	save_data.game_time = game_time
	
	save_data.max_health = player.max_health
	save_data.health = player.health
	save_data.deck = deck
	save_data.items = items
	save_data.board_state = board.board_state
	
	save_data.save_data()

func run_proceed():
	save_game()
	
	progress += 1
	create_next.emit()

func add_element_to_deck(data : ElementData):
	deck.append(data)

func remove_element_from_deck(data : ElementData):
	deck.erase(data)

func pick_element_randomly() -> ElementData:
	return deck[Random.get_randi(deck.size())]

func add_item_to_inventory(item_data : ItemData):
	var item_inst := ITEM_SCENE.instantiate()
	item_inst.data = item_data
	
	inventory.add_child(item_inst)
	
	Pool.remove_item_in_pool(item_data)

func check_items(type : ItemData.Type):
	for item in items:
		if item.type == type:
			item.effect()

func _on_timer_timeout() -> void:
	game_time += 1
