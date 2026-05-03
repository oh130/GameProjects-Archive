class_name PlayerInfo extends Control

@onready var strength: Label = %Strength
@onready var intelligence: Label = %Intelligence
@onready var dexterity: Label = %Dexterity
@onready var faith: Label = %Faith
@onready var crit: Label = %Crit
@onready var armor_pen: Label = %ArmorPen
@onready var armor: Label = %Armor
@onready var dodge: Label = %Dodge

var data : PlayerData : set = set_data

func set_data(player_data : PlayerData):
	data = player_data
	
	update_stats()

func update_stats():
	if not data:
		return
	
	strength.text = "%d" % data.applied_stats[Enum.Stat.STRENGTH]
	intelligence.text = "%d" % data.applied_stats[Enum.Stat.INTELLIGENCE]
	dexterity.text = "%d" % data.applied_stats[Enum.Stat.DEXTERITY]
	faith.text = "%d" % data.applied_stats[Enum.Stat.FAITH]
	crit.text = "%d%% | %d%%" % [data.applied_stats[Enum.Stat.CRIT], data.applied_stats[Enum.Stat.CRIT_MUL]]
	armor_pen.text = "%d | %d%%" % [data.applied_stats[Enum.Stat.ARMOR_PEN], data.applied_stats[Enum.Stat.ARMOR_PEN_RATE]]
	armor.text = "%d(%d%%)" % [data.applied_stats[Enum.Stat.ARMOR], 100 * (1 - (100.0 / (100 + data.applied_stats[Enum.Stat.ARMOR])))]
	dodge.text = "%d%%" % [data.applied_stats[Enum.Stat.DODGE]]
	
