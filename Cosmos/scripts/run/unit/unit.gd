class_name Unit extends Control

@onready var sprite: Sprite2D = %Sprite
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var ui: Control = %UI
@onready var input_controller: Control = %InputController
@onready var focus_particle: CPUParticles2D = %FocusParticle

@onready var health_bar: ExtendedBar = %HealthBar
@onready var energy_bar: ExtendedBar = %EnergyBar
@onready var shield_label: Label = %ShieldLabel

@onready var targetable_icon: Sprite2D = %TargetableIcon
@onready var buff_container: BuffContainer = %BuffContainer
@onready var status_container: StatusContainer = %StatusContainer

var data : UnitData : set = set_data

var is_highlighted := false : set = set_highlighted
var is_targetable := false : set = set_targetable

var cur_buff_arr : Array[RefinedBuff]
var cur_status_arr : Array[int]
var is_died := false

var orig_pos : Vector2

signal stat_changed()
signal died()
signal focus_unit(unit : Unit)
signal unfocus_unit()
signal select_unit(unit : Unit)

func _ready():
	SituationManager.situation_occured_signal.connect(situation_occured)
	
	input_controller.mouse_entered.connect(_on_mouse_entered)
	input_controller.mouse_exited.connect(_on_mouse_exited)
	input_controller.gui_input.connect(_on_gui_input)
	
	cur_status_arr.resize(Enum.Status.size())
	
	focus_particle.hide()
	targetable_icon.hide()
	shield_label.hide()

func set_data(unit_data : UnitData):
	data = unit_data
	
	# set and resize sprite.
	sprite.texture = data.sprite
	
	if self is Enemy:
		sprite.scale.x = data.sprite_width / sprite.texture.get_width()
	else:
		sprite.scale.x = health_bar.size.x / sprite.texture.get_width()
	
	sprite.scale.y = sprite.scale.x
	sprite.position = Vector2(0, -0.5 * sprite.texture.get_height() * sprite.scale.y)
	
	input_controller.size = sprite.texture.get_size() * sprite.scale
	input_controller.position = Vector2(-0.5 * input_controller.size.x, -input_controller.size.y)
	orig_pos = sprite.position
	targetable_icon.position = sprite.position
	
	set_applied_stats()
	data.health_changed.connect(health_changed)
	data.energy_changed.connect(energy_changed)
	data.shield_changed.connect(set_shield_ui)
	data.shield = 0

func combat_start():
	pass

func turn_start():
	# take rift effect.
	if cur_status_arr[Enum.Status.RIFT] > 0:
		data.health -= cur_status_arr[Enum.Status.RIFT]
		cur_status_arr[Enum.Status.RIFT] /= 2
		SubInfoLayer.make_indicator({Enum.IndicateType.DMG: cur_status_arr[Enum.Status.RIFT]}, targetable_icon.global_position)

func turn_end():
	pass

# Execute when stat changed.
# Stat change situation: level up, get equipment, use consumable, get (de)buff, get status.
func set_applied_stats():
	var prev_max_hp := data.applied_stats[Enum.Stat.MAX_HEALTH]
	var prev_max_en := data.applied_stats[Enum.Stat.MAX_ENERGY]
	
	# STEP 0: copy pure amount of stats(not affected by ratios).
	for stat in data.stats:
		data.applied_stats[stat] = roundi(data.stats[stat].amount)
	
	# STEP 1: fixed effects.
	for buff : RefinedBuff in cur_buff_arr:
		for stat in buff.stat_buffs:
			data.applied_stats[stat] += buff.stat_buffs[stat]
	
	# STEP 2: percentage effects.
	if cur_status_arr[Enum.Status.OVERBREATHING] > 0:
		data.applied_stats[Enum.Stat.DODGE] =\
		roundi(data.applied_stats[Enum.Stat.DODGE] / pow(2, cur_status_arr[Enum.Status.OVERBREATHING]))
	
	for stat in data.stats:
		if not data.stats[stat].ratios.is_empty():
			for ratio_key in data.stats[stat].ratios:
				data.applied_stats[stat] = roundi(data.applied_stats[stat] +\
				data.stats[stat].ratios[ratio_key] * data.applied_stats[ratio_key])
	
	# STEP 3: effects belong with other stats.
	#for p in data.passives:
		#pass
	
	stat_changed.emit()
	health_bar.set_val_with_max(data.health, get_unsigned_stat(Enum.Stat.MAX_HEALTH))
	energy_bar.set_val_with_max(data.energy, get_unsigned_stat(Enum.Stat.MAX_ENERGY))
	
	if data.applied_stats[Enum.Stat.MAX_HEALTH] > prev_max_hp:
		data.health += data.applied_stats[Enum.Stat.MAX_HEALTH] - prev_max_hp
	if data.applied_stats[Enum.Stat.MAX_ENERGY] > prev_max_en:
		data.energy += data.applied_stats[Enum.Stat.MAX_ENERGY] - prev_max_en

func health_changed(val : int):
	health_bar.set_val_with_max(val, get_unsigned_stat(Enum.Stat.MAX_HEALTH))
	
	if val == 0:
		death()

func death():
	is_died = true
	sprite.material = null
	animation_player.play("death")
	died.emit()

func energy_changed(val : int):
	energy_bar.set_val_with_max(val, get_unsigned_stat(Enum.Stat.MAX_ENERGY))

func exhaust():
	change_status(Enum.Status.EXHAUST, 1)
	if cur_status_arr[Enum.Status.DEFENSELESS] == 0:
		change_status(Enum.Status.DEFENSELESS, 1)
	if cur_status_arr[Enum.Status.EXHAUST] == 5:
		death()

func set_shield_ui():
	shield_label.text = str(data.shield)
	
	if data.shield == 0:
		shield_label.hide()
		health_bar.set_shield(false)
	else:
		shield_label.show()
		health_bar.set_shield(true)

func set_highlighted(value : bool):
	is_highlighted = value
	
	if is_highlighted:
		var tween := create_tween()
		tween.set_parallel(false)
		tween.tween_property(sprite, "scale", 1.1 * sprite.scale, 0.1)
		tween.tween_property(sprite, "scale", sprite.scale, 0.1)
	
		focus_particle.show()
	else:
		focus_particle.hide()

func set_targetable(value : bool):
	is_targetable = value
	targetable_icon.visible = value
	
	if value:
		var tween := create_tween()
		tween.set_parallel(false)
		tween.tween_property(targetable_icon, "scale", Vector2(0.3,0.3), 0.1)
		tween.tween_property(targetable_icon, "scale", Vector2(0.2,0.2), 0.1)

# return result of effect.
func take_effect(values : Dictionary[SkillEffects.Effect, int], is_crit := false) -> Dictionary[SkillEffects.Effect, int]:
	if values.is_empty() and not is_crit:
		return values
	
	# resilience.
	for effect in values:
		if effect in [SkillEffects.Effect.HEAL, SkillEffects.Effect.GAIN_ENERGY, SkillEffects.Effect.SHIELD]:
			values[effect] += roundi(values[effect] * get_unsigned_stat(Enum.Stat.RESILIENCE))
		else:
			values[effect] += roundi(values[effect] * get_unsigned_stat(Enum.Stat.TAKE_DMG_AMP))
	
	var indicate_dict : Dictionary[Enum.IndicateType, int]
	
	for val in values:
		match val:
			SkillEffects.Effect.DMG:
				indicate_dict[Enum.IndicateType.DMG] = values[val]
				if data.shield >= values[val]:
					data.shield -= values[val]
					continue
				elif data.shield > 0:
					values[val] -= data.shield
					data.shield = 0
				
				data.health -= values[val]
				
			SkillEffects.Effect.ENERGY_DMG:
				indicate_dict[val] = values[val]
				if data.energy <= values[val]:
					exhaust()
				data.energy -= values[val]
				
			SkillEffects.Effect.HEAL:
				indicate_dict[val] = values[val]
				data.health += values[val]
				
			SkillEffects.Effect.GAIN_ENERGY:
				indicate_dict[val] = values[val]
				data.energy += values[val]
				
			SkillEffects.Effect.SHIELD:
				indicate_dict[val] = values[val]
				data.shield += values[val]
	
	if is_crit:
		indicate_dict[Enum.IndicateType.CRIT] = 0
	
	SubInfoLayer.make_indicator(indicate_dict, targetable_icon.global_position)
	
	return values

func situation_occured(situation : Enum.Situation):
	# erase temp buff with situation.
	var buff_erase_arr : Array[RefinedBuff]
	for buff in cur_buff_arr:
		if buff.temp_buff_end_timing == situation:
			buff_erase_arr.append(buff)
	
	if not buff_erase_arr.is_empty():
		for target in buff_erase_arr:
			cur_buff_arr.erase(target)
		manage_buff_ui()
	
	# check and occur passive effects.
	for passive in data.passives:
		if passive.effect_timing == situation:
			passive.effect(self)

func add_statuses(status_arr : Dictionary[Enum.Status, int]):
	if status_arr.is_empty():
		return
	
	for key in status_arr.keys():
		change_status(key, status_arr[key])
	manage_status_ui()

func change_status(status : Enum.Status, amount : int):
	if amount == 0:
		return
	
	cur_status_arr[status] = clampi(cur_status_arr[status] + amount, 0, 999)
	manage_status_ui()

func erase_all_status():
	for i in cur_status_arr.size():
		cur_status_arr[i] = 0
	manage_status_ui()

func manage_status_ui():
	status_container.set_statuses(cur_status_arr)
	set_applied_stats()

func affect_buff(buff : RefinedBuff):
	if buff == null:
		return
	
	cur_buff_arr.append(buff)
	#buff_container.add_buff_anim()
	manage_buff_ui()

func erase_all_buff():
	cur_buff_arr.clear()
	manage_buff_ui()

func manage_buff_ui():
	buff_container.set_buffs(cur_buff_arr)
	set_applied_stats()

func get_unsigned_stat(stat : Enum.Stat) -> int:
	return data.applied_stats[stat] if data.applied_stats[stat] > 0 else 0

func get_all_unsigned_stat() -> Dictionary[Enum.Stat, int]:
	var ret : Dictionary[Enum.Stat, int]
	for key in data.applied_stats:
		ret[key] = data.applied_stats[key] if data.applied_stats[key] > 0 else 0
	
	return ret

func _on_mouse_entered() -> void:
	if GameManager.deny_input or is_died:
		return
	
	targetable_icon.scale = Vector2(0.3,0.3)
	sprite.material.set("shader_parameter/brightness", 1.2)
	focus_unit.emit(self)

func _on_mouse_exited() -> void:
	if GameManager.deny_input or is_died:
		return
	
	targetable_icon.scale = Vector2(0.2,0.2)
	sprite.material.set("shader_parameter/brightness", 1)
	unfocus_unit.emit()

func _on_gui_input(event: InputEvent) -> void:
	if GameManager.deny_input or is_died:
		return
	
	if event.is_action_pressed("left_mouse"):
		select_unit.emit(self)
