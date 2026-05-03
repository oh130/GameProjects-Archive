extends Control

@onready var playable_characters = $PlayableCharacters/HBoxContainer
@onready var current_roster = $Roster
@onready var embark = $Embark
@onready var character_info = $CharacterInfo.get_children()

@export var game_manager : PackedScene
@export var tavern_player_icon : PackedScene

func _ready():
	load_playable_characters()
	connect_signals()

func load_playable_characters():
	for pun in GlobalData.player_unit_names:
		var icon : TextureRect = tavern_player_icon.instantiate()
		icon.property = {"texture" : GlobalData.portraits[pun], "unit_name" : pun}
		playable_characters.add_child(icon)

func connect_signals():
	for i in playable_characters.get_child_count():
		playable_characters.get_child(i).gui_input.connect(icon_clicked.bind(i))
	embark.pressed.connect(embark_clicked)
	
func icon_clicked(event : InputEvent, character_idx : int):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			character_info[0].text = tr("CLASS_" + str(character_idx))
			character_info[1].text = tr("SPECIES_" + str(character_idx))
			character_info[2].text = tr("ROLE_GROUP_" + str(character_idx))

func embark_clicked():
	var arr : Array[String]
	var check : bool = false
	
	for char in current_roster.get_children():
		arr.append(char.property["unit_name"])
		if char.property["unit_name"] != Enum.EMPTY:
			check = true
			
	if not check:
		return
	
	var GM = game_manager.instantiate()
	GM.init_game_manager(arr)
	get_parent().add_child(GM)
	
	self.hide()
