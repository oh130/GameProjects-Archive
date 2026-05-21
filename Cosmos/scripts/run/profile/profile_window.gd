class_name ProfileWindow extends Control

const STAT_BLOCK_SCENE := preload("res://scenes/run/profile/stat_block.tscn")
const SKILL_UI_SCENE := preload("res://scenes/run/profile/profile_skill_ui.tscn")
const ITEM_UI_SCENE := preload("res://scenes/run/item/item_ui.tscn")

@onready var unit_preview: TextureRect = %UnitPreview
@onready var unit_id: Label = %UnitID
@onready var exp_bar: ProgressBar = %ExpBar
@onready var level_label: Label = %LevelLabel

@onready var player_buttons: Control = %PlayerButtons
@onready var stat_blocks: VBoxContainer = %StatBlocks
@onready var skill_container: GridContainer = %SkillContainer
@onready var equipment_container: GridContainer = %EquipmentContainer

var data : PlayerData : set = set_data
var added_equipments : Dictionary[Equipment, int]
var eq_map : Dictionary[Equipment, ItemUI]

func _ready():
	hide()

func set_data(player_data : PlayerData):
	data = player_data
	
	unit_preview.texture = data.preview
	unit_id.text = data.resource_name
	exp_bar.max_value = data.cur_exp_for_up
	exp_bar.value = data.cur_exp
	level_label.text = "Lv.%d" % data.applied_stats[Enum.Stat.LEVEL]
	
	for stat in data.stats:
		if stat > Enum.Stat.ARMOR_PEN_RATE:
			break
		
		var stat_block := STAT_BLOCK_SCENE.instantiate()
		stat_blocks.add_child(stat_block)
		(stat_block.get_child(0) as TextureRect).texture = SubInfoLayer.stat_icons[stat]
		(stat_block.get_child(1) as Label).text = "%d" % data.applied_stats[stat]
		if data.stat_up_per_level.has(stat):
			(stat_block.get_child(2) as Label).text = "(+%s)" % SubInfoLayer.get_float_str(data.stat_up_per_level[stat])
			stat_block.get_child(2).show()
		else:
			stat_block.get_child(2).hide()
	
	for skill in data.skills:
		var skill_ui := SKILL_UI_SCENE.instantiate()
		skill_container.add_child(skill_ui)
		skill_ui.player_data = data
		skill_ui.data = skill
		skill_ui.selected = data.selected_skills.has(skill)
	
	for equipment in data.equipments:
		var item_ui : TextureRect = ITEM_UI_SCENE.instantiate()
		item_ui.custom_minimum_size = Vector2(60,60)
		equipment_container.add_child(item_ui)
		item_ui.data = equipment
		item_ui.count = data.equipments[equipment]
		added_equipments[equipment] = data.equipments[equipment]
		eq_map[equipment] = item_ui

func update_profile():
	for stat in data.stats:
		if stat > Enum.Stat.ARMOR_PEN_RATE:
			break
		
		(stat_blocks.get_child(stat).get_child(1) as Label).text = "%d" % data.applied_stats[stat]
	
	for skill_ui : ProfileSkillUI in skill_container.get_children():
		skill_ui.set_enhanced_texture()
	
	for equipment in data.equipments:
		if not added_equipments.has(equipment):
			var item_ui : TextureRect = ITEM_UI_SCENE.instantiate()
			item_ui.custom_minimum_size = Vector2(60,60)
			equipment_container.add_child(item_ui)
			item_ui.data = equipment
			item_ui.count = data.equipments[equipment]
			eq_map[equipment] = item_ui
		
		elif added_equipments[equipment] != data.equipments[equipment]:
			eq_map[equipment].count = data.equipments[equipment]
		
		added_equipments[equipment] = data.equipments[equipment]
