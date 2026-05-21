class_name Indicator extends Control

@onready var specific_label: Label = %SpecificLabel
@onready var dmg_label: Label = %DmgLabel
@onready var energy_dmg_label: Label = %EnergyDmgLabel
@onready var heal_label: Label = %HealLabel
@onready var gain_energy_label: Label = %GainEnergyLabel
@onready var shield_label: Label = %ShieldLabel

func _ready():
	for child : Label in get_children():
		child.hide()

func set_indicator(indicate_dict : Dictionary[Enum.IndicateType, int], pos : Vector2):
	for val in indicate_dict:
		match val:
			Enum.IndicateType.DMG:
				dmg_label.text = str(indicate_dict[val])
				dmg_label.show()
			Enum.IndicateType.ENERGY_DMG:
				energy_dmg_label.text = str(indicate_dict[val])
				energy_dmg_label.show()
			Enum.IndicateType.HEAL:
				heal_label.text = str(indicate_dict[val])
				heal_label.show()
			Enum.IndicateType.GAIN_ENERGY:
				gain_energy_label.text = str(indicate_dict[val])
				gain_energy_label.show()
			Enum.IndicateType.SHIELD:
				shield_label.text = str(indicate_dict[val])
				shield_label.show()
			
			_:
				specific_label.text = str(Enum.IndicateType.keys()[val])
				specific_label.show()
	
	start_indicate(pos)

func start_indicate(pos : Vector2):
	reset_size()
	position = pos + Vector2(0,-30) - size / 2
	
	var tween := create_tween()
	tween.tween_property(self, "position", position + 30 * Vector2.UP, 1)
	await tween.finished
	queue_free()

func remove_indicator(immidiate : bool):
	if immidiate:
		queue_free()
	else:
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 0, 0.1)
		await tween.finished
		queue_free()
