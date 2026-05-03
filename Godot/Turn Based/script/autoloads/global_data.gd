extends Node

# pathes
var player_dir_path : String = "res://data/unit_data/player_data/"
var enemy_dir_path : String = "res://data/unit_data/enemy_data/"
var move_skill_path : String = "res://data/public_data/move.json"
var player_anim_texture_path : String = "res://images/anim_textures/player/"
var enemy_anim_texture_path : String = "res://images/anim_textures/enemy/"
var player_portrait_path : String = "res://images/portraits/player/"
var enemy_portrait_path : String = "res://images/portraits/enemy/"
var player_id_path : String = "res://data/unit_data/player_id.json"
var enemy_id_path : String = "res://data/unit_data/enemy_id.json"

# combat
var indicator : PackedScene = preload("res://scene/instances/indicator.tscn")
var turn_list_portrait : PackedScene = preload("res://scene/instances/turn_list_portrait.tscn")
# map
var combat_tile : PackedScene = preload("res://scene/instances/combat_tile.tscn")
# unit
var unit_scene : PackedScene = preload("res://scene/unit/unit.tscn")

var unit_given_turn : Dictionary
var unit_stat : Dictionary
var unit_skills : Dictionary
var unit_riposte : Dictionary
var unit_assist : Dictionary

var move_skill : Dictionary

var portraits : Dictionary

var anim_textures : Dictionary

var player_unit_names : Array
var enemy_unit_names : Array

var str_to_stat : Dictionary = {
	"ad" : Enum.Stat.AD,
	"ap" : Enum.Stat.AP,
	"arm" : Enum.Stat.ARM,
	"mag_res" : Enum.Stat.MAG_RES,
	"crit" : Enum.Stat.CRIT,
	"crit_dmg" : Enum.Stat.CRIT_DMG,
	"speed" : Enum.Stat.SPEED,
	"dodge" : Enum.Stat.DODGE,
	"accuracy" : Enum.Stat.ACCURACY,
	"vamp" : Enum.Stat.VAMP,
	"vigor" : Enum.Stat.VIGOR,
	"move_res": Enum.Stat.MOVE_RES,
	"arm_pen" : Enum.Stat.ARM_PEN,
	"arm_pen_per" : Enum.Stat.ARM_PEN_PER,
	"mag_pen" : Enum.Stat.MAG_PEN,
	"mag_pen_per" : Enum.Stat.MAG_PEN_PER
}

func _ready():
	load_unit_names()
	load_portraits()
	load_anim_textures()
	load_unit_data()
	load_move()

func load_unit_names():
	var file1 : FileAccess = FileAccess.open(player_id_path, FileAccess.READ)
	player_unit_names = JSON.parse_string(file1.get_as_text())
	
	var file2 : FileAccess = FileAccess.open(enemy_id_path, FileAccess.READ)
	enemy_unit_names = JSON.parse_string(file2.get_as_text())

func load_portraits():
	var player_portrait_file_names : PackedStringArray =  DirAccess.open(player_portrait_path).get_files()
	var enemy_portrait_file_names : PackedStringArray =  DirAccess.open(enemy_portrait_path).get_files()
	
	
	for file_name in player_portrait_file_names:
		if file_name.get_extension() == "import":
			continue
		var portrait : Image = Image.new()
		var unit_name : String = file_name.get_basename()
		portrait.load(player_portrait_path + file_name)
		portraits[unit_name] = ImageTexture.create_from_image(portrait)
	
	for file_name in enemy_portrait_file_names:
		if file_name.get_extension() == "import":
			continue
		var portrait : Image = Image.new()
		var unit_name : String = file_name.get_basename()
		portrait.load(enemy_portrait_path + file_name)
		portraits[unit_name] = ImageTexture.create_from_image(portrait)

func load_anim_textures():
	var player_anim_texture_file_names : PackedStringArray =  DirAccess.open(player_anim_texture_path).get_files()
	var enemy_anim_texture_file_names : PackedStringArray =  DirAccess.open(enemy_anim_texture_path).get_files()
	
	for file_name in player_anim_texture_file_names:
		if file_name.get_extension() == "import":
			continue
		var anim_texture : Image = Image.new()
		var unit_name : String = file_name.get_basename()
		anim_texture.load(player_anim_texture_path + file_name)
		anim_textures[unit_name] = ImageTexture.create_from_image(anim_texture)
	
	for file_name in enemy_anim_texture_file_names:
		if file_name.get_extension() == "import":
			continue
		var anim_texture : Image = Image.new()
		var unit_name : String = file_name.get_basename()
		anim_texture.load(enemy_anim_texture_path + file_name)
		anim_textures[unit_name] = ImageTexture.create_from_image(anim_texture)

func load_unit_data():
	var player_data_file_names : PackedStringArray = DirAccess.open(player_dir_path).get_files()
	var enemy_data_file_names : PackedStringArray = DirAccess.open(enemy_dir_path).get_files()
	var file : FileAccess
	var parsed_data : Dictionary
	var unit_name : String
	
	for file_name in player_data_file_names:
		file = FileAccess.open(player_dir_path + file_name, FileAccess.READ)
		parsed_data = JSON.parse_string(file.get_as_text())
		unit_name = parsed_data["name"]
		
		unit_given_turn[unit_name] = parsed_data["given_turn"] as int
		unit_stat[unit_name] = (parsed_data["stat"] as Dictionary).values()
		unit_skills[unit_name] = parsed_data["skills"]
		if "riposte" in parsed_data:
			unit_riposte[unit_name] = parsed_data["riposte"]
		if "assist" in parsed_data:
			unit_assist[unit_name] = parsed_data["assist"]
		
		file.close()
		
	for file_name in enemy_data_file_names:
		file = FileAccess.open(enemy_dir_path + file_name, FileAccess.READ)
		parsed_data = JSON.parse_string(file.get_as_text())
		unit_name = parsed_data["name"]
		
		unit_given_turn[unit_name] = parsed_data["given_turn"] as int
		unit_stat[unit_name] = (parsed_data["stat"] as Dictionary).values()
		unit_skills[unit_name] = parsed_data["skills"]
		if "riposte" in parsed_data:
			unit_riposte[unit_name] = parsed_data["riposte"]
		if "assist" in parsed_data:
			unit_assist[unit_name] = parsed_data["assist"]
		
		file.close()

func load_move():
	var file : FileAccess = FileAccess.open(move_skill_path, FileAccess.READ)
	move_skill = JSON.parse_string(file.get_as_text())

func make_damage_indicator(damage : int, dmg_type : int, global_pos : Vector2):
	var _indicator : Node2D = indicator.instantiate()
	var label : Label = _indicator.get_child(0)
	get_tree().get_current_scene().add_child(_indicator)
	_indicator.global_position = global_pos
	
	match dmg_type:
		Enum.DmgType.EG:
			if damage < 0:
				_indicator.position.y -= 50
				label.modulate = Color.YELLOW_GREEN
				label.text = str(-damage)
			else:
				_indicator.position.y -= 50
				label.modulate = Color.YELLOW
				label.text = str(damage)
		Enum.DmgType.AD:
			_indicator.position.y -= 25
			_indicator.position.x += 25
			label.modulate = Color.RED
			label.text = str(damage)
		Enum.DmgType.AP:
			_indicator.position.y -= 25
			_indicator.position.x -= 25
			label.modulate = Color.BLUE
			label.text = str(damage)
		Enum.DmgType.PR:
			if damage < 0:
				_indicator.position.y -= 25
				_indicator.position.x -= 25
				label.modulate = Color.GREEN
				label.text = str(-damage)
			else:
				_indicator.position.y -= 25
				label.text = str(damage)
			
	_indicator.position.y -= 50

func make_status_indicator(_text : String, global_pos : Vector2):
	var _indicator : Node2D = indicator.instantiate()
	get_tree().get_current_scene().add_child(_indicator)
	_indicator.global_position = global_pos
	_indicator.get_child(0).text = _text
	_indicator.position.y -= 50
