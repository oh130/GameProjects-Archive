class_name Player extends Node2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var armor_label: Label = %ArmorLabel

var max_health : int : set = set_max_health
var health : int : set = set_health
var armor : int : set = set_armor

signal died()

func _ready():
	GameManager.player = self

func set_max_health(value : int):
	max_health = value
	if not is_node_ready():
		await ready
	
	if max_health < health:
		health = max_health
	
	health_bar.max_value = max_health

func set_health(value : int):
	health = clampi(value, 0, max_health)
	if not is_node_ready():
		await ready
	
	health_bar.value = health
	health_label.text = "%d / %d" % [health, max_health]
	
	if health == 0:
		animation_player.play("death")
		died.emit()

func set_armor(value : int):
	armor = clampi(value, 0, 9223372036854775807)
	
	if armor == 0:
		armor_label.hide()
	else:
		armor_label.text = str(armor)
		armor_label.show()

func get_armor(amount : int):
	armor += amount

func take_damage(amount : int):
	if armor >= amount:
		armor -= amount
		SubInfoLayer.make_indicator(amount, Indicator.Type.ARMOR_NEGATIVE, global_position)
		return
		
	elif armor > 0:
		SubInfoLayer.make_indicator(armor, Indicator.Type.ARMOR_NEGATIVE, global_position)
		amount -= armor
		armor = 0
	
	health -= amount
	SubInfoLayer.make_indicator(amount, Indicator.Type.HEALTH_NEGATIVE, global_position)

func heal(amount : int):
	health += amount
	SubInfoLayer.make_indicator(amount, Indicator.Type.HEALTH_POSITIVE, global_position)
