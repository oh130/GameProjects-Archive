class_name Run extends Node

const PLAYER_SCENE := preload("res://scenes/run/unit/player.tscn")
const CHAPTER_BUTTON := preload("res://scenes/run/chapter_button.tscn")

@onready var background: TextureRect = %Background

@onready var combat: Combat = %Combat
@onready var shop: Shop = %Shop
@onready var encounter: Encounter = %Encounter

@onready var inventory: Inventory = %Inventory
@onready var route_choice: RouteChoice = %RouteChoice
@onready var enhancement_select: EnhancementSelect = %EnhancementSelect
@onready var highlight_screen: ColorRect = %HighlightScreen
@onready var reward: Reward = %Reward
@onready var profile_window_container: ProfileWindowContainer = %ProfileWindowContainer

@onready var player_container: HBoxContainer = %PlayerContainer
@onready var player_info: PlayerInfo = %PlayerInfo
@onready var gold_label: Label = %GoldLabel
@onready var difficulty_label: Label = %DifficultyLabel

@onready var game_over_ui: ColorRect = %GameOverUI
@onready var chapter_choice: ColorRect = %ChapterChoice
@onready var chapter_choice_buttons: HBoxContainer = %ChapterChoiceButtons

var gold : int : set = set_gold
var displayed_gold : int : set = set_displayed_gold

var players : Array[Player]
var focused_player : Player : set = set_focused_player

func _ready():
	DataManager.run = self
	SituationManager.refresh_dialog_arrs()
	
	for chapter : Chapter in Pool.chapter_pool:
		var button := CHAPTER_BUTTON.instantiate()
		chapter_choice_buttons.add_child(button)
		
		button.chapter = chapter
		button.pressed.connect(chapter_choose.bind(chapter))
	
	combat.combat_end_signal.connect(combat_ended)
	combat.game_over_signal.connect(game_over)
	
	route_choice.route_entered.connect(enter_route)
	route_choice.chapter_ended.connect(chapter_clear)
	
	game_over_ui.hide()
	
	DataManager.start_game()
	focused_player = players.front()

func load_run():
	inventory.load_inventory()
	profile_window_container.init_profile()
	create_players()
	
	if DataManager.save_data.chapter:
		background.texture = DataManager.save_data.chapter.background
		Audio.play_bgm(DataManager.save_data.chapter.bgm)
		enter_route(DataManager.save_data.current_route)
	else:
		show_chapter_choice()

func show_chapter_choice():
	for chapter_button : ChapterButton in chapter_choice_buttons.get_children():
		if DataManager.save_data and\
		DataManager.save_data.cleared_chapters.has(chapter_button.chapter.resource_name):
			chapter_button.disabled = true
	
	SituationManager.on_chapter_choice = true
	chapter_choice.show()

func chapter_choose(chapter : Chapter):
	SituationManager.on_chapter_choice = false
	chapter_choice.hide()
	
	DataManager.save_data.chapter = chapter
	background.texture = chapter.background
	Audio.play_bgm(chapter.bgm)
	enter_route(Enum.Route.CHAPTER_ENTER)
	
	for p in players:
		SituationManager.occur(Enum.Situation.CHAPTER_ENTER, p, chapter)

func chapter_clear():
	DataManager.save_data.cleared_chapters.append(DataManager.save_data.chapter.resource_name)
	DataManager.save_data.chapter = null
	show_chapter_choice()

func create_players():
	for i in DataManager.player_datas.size():
		var player_data := DataManager.player_datas[i]
		if player_data.health <= 0:
			continue
		
		var inst := PLAYER_SCENE.instantiate()
		player_container.add_child(inst)
		players.append(inst)
		
		inst.data = player_data
		inst.stat_changed.connect(profile_window_container.update_profiles)
		inst.select_unit.connect(player_clicked)
		inst.awake_level_reached.connect(show_enhancement_select)
		
		combat.append_player(inst)

func player_clicked(player : Player):
	if not SituationManager.on_combat:
		focused_player = player

func set_focused_player(player : Player):
	var same_flag := (focused_player == player)
	if focused_player and not same_flag:
		focused_player.is_highlighted = false
	
	focused_player = player
	
	if player:
		if not same_flag:
			player_info.data = player.data
			player.is_highlighted = true
			
			if not SituationManager.on_chapter_choice:
				Audio.play_sfx(Audio.unit_focusing)
		
		if not SituationManager.on_combat:
			encounter.focused_player_changed()

func equip_equipment(equipment : Equipment):
	SituationManager.occur(Enum.Situation.GET_EQUIPMENT, focused_player, equipment)
	focused_player.add_equipment(equipment)

func use_consumable(consumable : Consumable):
	consumable.effect(focused_player)
	SituationManager.occur(Enum.Situation.USE_CONSUMABLE, focused_player, consumable)
	inventory.erase_item_from_inventory(consumable)
	focused_player.set_applied_stats()

func sell_consumable(consumable : Consumable):
	Audio.play_sfx(Audio.buy_sell)
	DataManager.run.gold += int(Shop.CONSUMABLE_PRICE * Shop.BASE_REFUND_MUL)
	inventory.erase_item_from_inventory(consumable)

func show_enhancement_select(player : Player):
	focused_player = player
	
	player.z_index = 1
	highlight_screen.show()
	enhancement_select.show_enhancements()

func give_enhancement_to_player(enh : Enhancement):
	if enh:
		focused_player.get_enhancement(enh)
	
	focused_player.z_index = 0
	highlight_screen.hide()
	
	SituationManager.on_enh_select = false

func set_gold(new_gold: int):
	gold = new_gold
	var tween := create_tween()
	tween.tween_property(self, "displayed_gold", new_gold, 1)

func set_displayed_gold(value: int):
	displayed_gold = value
	gold_label.text = str(displayed_gold)

func combat_ended():
	Audio.stop_bgm()
	reward.get_combat_rewards()
	await Audio.play_sfx(Audio.win)
	Audio.play_bgm(DataManager.save_data.chapter.bgm)

func enter_route(route : Enum.Route):
	SituationManager.usual_state = false
	route_choice.hide()
	shop.hide()
	encounter.hide()
	difficulty_label.text = str(DataManager.save_data.difficulty)
	
	if route == Enum.Route.CHAPTER_EXIT:
		return
	
	match route:
		Enum.Route.ENCOUNTER:
			encounter.enter_encounter()
		Enum.Route.CHAPTER_ENTER:
			show_route_choice()
		Enum.Route.SHOP:
			shop.enter_shop()
		_:
			combat.start_combat(route)
	
	get_next_routes()

func get_next_routes():
	route_choice.get_next_routes()

func show_route_choice():
	SituationManager.usual_state = true
	route_choice.show()

func game_over():
	DataManager.game_over()
	Audio.stop_bgm()
	#await Audio.play_sfx(Audio.defeat)
	await get_tree().create_timer(1.5).timeout
	
	GameManager.show_tween(game_over_ui, 1)

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Engine.time_scale = 0.1
	else:
		Engine.time_scale = 1
