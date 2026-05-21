class_name EnemyInfo extends Control

@onready var power: Label = %Power
@onready var armor: Label = %Armor
@onready var armor_pen: Label = %ArmorPen

@onready var impact: Label = %Impact
@onready var slash: Label = %Slash
@onready var pierce: Label = %Pierce
@onready var nature: Label = %Nature
@onready var arcane: Label = %Arcane
@onready var mystic: Label = %Mystic

@onready var impact_weak_icon: TextureRect = %ImpactWeakIcon
@onready var slash_weak_icon: TextureRect = %SlashWeakIcon
@onready var pierce_weak_icon: TextureRect = %PierceWeakIcon
@onready var nature_weak_icon: TextureRect = %NatureWeakIcon
@onready var arcane_weak_icon: TextureRect = %ArcaneWeakIcon
@onready var mystic_weak_icon: TextureRect = %MysticWeakIcon

var data : EnemyData : set = set_data
var labels : Array[Label]
var weak_icons : Array[TextureRect]

func _ready() -> void:
	labels.append(impact)
	labels.append(slash)
	labels.append(pierce)
	labels.append(nature)
	labels.append(arcane)
	labels.append(mystic)
	
	weak_icons.append(impact_weak_icon)
	weak_icons.append(slash_weak_icon)
	weak_icons.append(pierce_weak_icon)
	weak_icons.append(nature_weak_icon)
	weak_icons.append(arcane_weak_icon)
	weak_icons.append(mystic_weak_icon)
	
	for icon in weak_icons:
		icon.hide()

func set_data(enemy_data : EnemyData):
	data = enemy_data
	
	update_stats()
	
	for att in Enum.Attribute.size():
		if att in data.weaknesses:
			labels[att].modulate = Color.RED
			weak_icons[att].show()
		else:
			labels[att].modulate = Color.WHITE
			weak_icons[att].hide()
		
		var val := data.att_mods[att]
		if val == 0:
			labels[att].text = "-"
		else:
			labels[att].text = "%+d%%" % [val]

func update_stats():
	if not data:
		return
	
	power.text = "%d" % data.applied_stats[Enum.Stat.STRENGTH]
	armor.text = "%d" % data.applied_stats[Enum.Stat.ARMOR]
	armor_pen.text = "%d" % data.applied_stats[Enum.Stat.ARMOR_PEN]
