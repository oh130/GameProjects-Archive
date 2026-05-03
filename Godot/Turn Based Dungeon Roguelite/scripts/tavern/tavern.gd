class_name Tavern extends Node

const ENTRY_BUTTON_SCENE := preload("res://scenes/tavern/entry_button.tscn")

const MAX_ROSTER := 3

@onready var entry: Control = %Entry

@onready var info: Control = %Info
@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var unit_preview: TextureRect = %UnitPreview

@onready var start_button: Button = %StartButton

@export_group("UI")
@export var roster_buttons : Array[Button]
@export var delete_buttons : Array[Button]
@export var bgm : AudioStream

var current_roster : Array[PlayerData] = [null, null, null]

var selected_roster_index := 0
var focused_player : PlayerData : set = set_focused_player

func _ready():
	Audio.play_bgm(bgm)
	
	for player in Pool.player_pool:
		var inst : Button = ENTRY_BUTTON_SCENE.instantiate()
		inst.icon = player.portrait
		inst.pressed.connect(entry_button_clicked.bind(player))
		entry.add_child(inst)
	
	var i := 0
	for button in roster_buttons:
		button.pressed.connect(roster_button_clicked.bind(i))
		i += 1
	
	i = 0
	for button in delete_buttons:
		button.pressed.connect(delete_button_clicked.bind(i))
		i += 1
	
	start_button.disabled = true
	
	info.hide()

func entry_button_clicked(player_data : PlayerData):
	focused_player = player_data
	
	if current_roster.has(player_data) and current_roster[selected_roster_index] != player_data:
		var prev_index := current_roster.find(player_data)
		current_roster[prev_index] = null
		roster_buttons[prev_index].icon = null
	
	current_roster[selected_roster_index] = player_data
	focused_player = player_data
	roster_buttons[selected_roster_index].icon = player_data.portrait
	
	start_button.disabled = false

func roster_button_clicked(index : int):
	if current_roster[index]:
		focused_player = current_roster[index]
	else:
		info.hide()
	
	selected_roster_index = index

func delete_button_clicked(index : int):
	if current_roster[index] and focused_player == current_roster[index]:
		focused_player = null
	
	roster_buttons[index].icon = null
	current_roster[index] = null
	
	var start_flag := false
	for i in 3:
		if current_roster[i]:
			start_flag = true
	
	if not start_flag:
		start_button.disabled = true

func set_focused_player(player_data : PlayerData):
	focused_player = player_data
	
	if player_data:
		name_label.text = player_data.resource_name
		description_label.text = "%s_DESC" % [player_data.resource_name]
		unit_preview.texture = player_data.preview
		info.show()
	else:
		info.hide()

func start_button_clicked():
	DataManager.player_datas.clear()
	
	# duplicate member one by one, and initialize.
	for p in current_roster:
		if not p:
			continue
		
		var data : PlayerData = p.duplicate()
		data.initialize()
		DataManager.player_datas.append(data)
	
	SceneManager.change_scene(SceneManager.GameScene.RUN)
