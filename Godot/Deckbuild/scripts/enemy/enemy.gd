class_name Enemy extends Node2D

enum ActionID
{
	ATTACK,
	DEFENSE,
}

const ACTION_ICONS : Array[AtlasTexture] =\
[
	preload("res://resources/sprites/property_icons/attack.tres"),
]

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var armor_label: Label = %ArmorLabel
@onready var intent_icon: TextureRect = %IntentIcon
@onready var tick_label: Label = %TickLabel

var data : EnemyData : set = set_data

var health : int : set = set_health
var armor : int : set = set_armor
var is_died := false

var preparing_action : EnemyAction : set = set_preparing_action
var action_remain_tick : int : set = set_tick

signal died()

func _ready():
	EventBus.commanded.connect(player_commanded)

func set_data(enemy_data : EnemyData):
	data = enemy_data
	
	health_bar.max_value = data.max_health
	health = data.max_health
	
	get_next_action()

func set_health(value : int):
	if is_died:
		return
	
	health = clampi(value, 0, data.max_health)
	health_bar.value = health
	health_label.text = "%d / %d" % [health, data.max_health]
	
	if health == 0:
		animation_player.play("death")
		is_died = true
		died.emit()

func set_armor(value : int):
	armor = clampi(value, 0, 9223372036854775807)
	
	if armor == 0:
		armor_label.hide()
	else:
		armor_label.text = str(armor)
		armor_label.show()

func set_preparing_action(action : EnemyAction):
	preparing_action = action
	
	intent_icon.texture = ACTION_ICONS[action.action_id]
	action_remain_tick = action.wait_tick

func set_tick(value : int):
	action_remain_tick = clampi(value, 0, 9223372036854775807)
	tick_label.text = str(action_remain_tick)

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

func player_commanded():
	action_remain_tick -= 1
	
	if action_remain_tick == 0:
		act()

func act():
	var val := preparing_action.associated_value
	
	match preparing_action.action_id:
		ActionID.ATTACK:
			# damage = associated value + strength.
			GameManager.player.take_damage(val)
		ActionID.DEFENSE:
			get_armor(val)
	
	get_next_action()

func check_action_condition(action_id : ActionID):
	match action_id:
		_:
			return true

func get_next_action():
	for action : EnemyAction in data.actions:
		if action.is_conditional and check_action_condition(action.action_id):
			preparing_action = action
			return
	
	if preparing_action and preparing_action.linked_action:
		preparing_action = preparing_action.linked_action
	else:
		# random choice.
		while true:
			var rand_action := data.actions[Random.get_randi(data.actions.size())]
			
			if not rand_action.is_conditional:
				preparing_action = rand_action
				return
