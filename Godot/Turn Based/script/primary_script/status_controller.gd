class_name StatusController extends Node2D

@onready var unit_ui = $UnitUI
@onready var health_bar = $UnitUI/HealthBar
@onready var health_label = $UnitUI/HealthBar/Health
@onready var energy_bar = $UnitUI/EnergyBar
@onready var energy_label = $UnitUI/EnergyBar/Energy
@onready var status_effects = $UnitUI/SEContainer.get_children()

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

@export var unit_name : String
@export var given_turn : int
@export var combat_pos : int

# they are current stats.
var unit_stat : Array[int]

# they are combat resource, should check remain amount.
var remain_health : int :
	set(value):
		remain_health = clamp(value, 0, unit_stat[Enum.Stat.HEALTH])
		health_bar.value = (remain_health as float / unit_stat[Enum.Stat.HEALTH]) * 100 as int
		health_label.text = str(remain_health) + ' / ' + str(unit_stat[Enum.Stat.HEALTH])
var remain_energy : int :
	set(value):
		remain_energy = clamp(value, 0, unit_stat[Enum.Stat.ENERGY])
		energy_bar.value = (remain_energy as float / unit_stat[Enum.Stat.ENERGY]) * 100
		energy_label.text = str(remain_energy) + ' / ' + str(unit_stat[Enum.Stat.ENERGY]) 
var remain_shield : int

# buff and debuffs.
var buffs : Array[BuffInfo]
var debuffs : Array[BuffInfo]
var fixed_buff_amounts : Array[int]
var percent_buff_amounts : Array[int]

# status effects.
var remain_SE : Array[int]

# guard.
@export var guard_unit : StatusController

# boolean variables.
@export var is_enemy : bool
@export var is_die : bool

func unit_created(_unit_name : String, _combat_pos : int, _is_enemy : bool):
	unit_name = _unit_name
	combat_pos = _combat_pos
	is_enemy = _is_enemy

func _ready():
	for se in status_effects:
		se.hide()
	
	connect_signal()
	resize_arr()
	init_unit_data()
	calculate_item_effects()

func connect_signal():
	anim_player.animation_finished.connect(on_animation_finished)
	GlobalSignal.guard_broken.connect(check_guard)

func resize_arr():
	unit_stat.resize(Enum.Stat.size())
	fixed_buff_amounts.resize(Enum.Stat.size())
	percent_buff_amounts.resize(Enum.Stat.size())
	remain_SE.resize(Enum.SE.size())

func init_unit_data():
	sprite.texture = GlobalData.anim_textures[unit_name]
	if is_enemy:
		sprite.flip_h = true
	
	given_turn = GlobalData.unit_given_turn[unit_name]
	
	for i in unit_stat.size():
		unit_stat[i] = GlobalData.unit_stat[unit_name][i] as int
	
	remain_health = unit_stat[Enum.Stat.HEALTH]
	remain_energy = unit_stat[Enum.Stat.ENERGY]
	remain_shield = unit_stat[Enum.Stat.SHIELD]

func calculate_item_effects():
	pass

func get_stat(stat_enum : int) -> int:
	return (unit_stat[stat_enum] + fixed_buff_amounts[stat_enum]) * (1 + 0.01 * percent_buff_amounts[stat_enum]) as int

func damage_health(amount : int) -> bool:
	remain_health -= amount
	if remain_health == 0:
		death()
		return true
	return false

func damage_energy(amount : int):
	remain_energy -= amount
	if remain_energy == 0:
		exhausted()

func drain_health(amount : int):
	remain_health += amount

func hit(dmg_arr : Array[int], crit_occur : bool, by_friend : bool):
	var tot_health_dmg : int = 0

	for i in dmg_arr.size():
		if dmg_arr[i] == 0:
			continue
			
		match i:
			Enum.DmgType.EG:
				damage_energy(dmg_arr[i])
				GlobalData.make_damage_indicator(dmg_arr[i], i, self.global_position)
			_:
				tot_health_dmg += dmg_arr[i]
				GlobalData.make_damage_indicator(dmg_arr[i], i, self.global_position)
	
	if damage_health(tot_health_dmg):
		return
	
	if crit_occur:
		crit_hit()
		
		if by_friend:
			play_anim("unit_animation/friendly")
		else:
			play_anim("unit_animation/crit_hit")
	else:
		if by_friend:
			play_anim("unit_animation/friendly")
		else:
			play_anim("unit_animation/hit")

func receive_buff_or_debuff(buff_arr : Array[BuffInfo]):
	for buff in buff_arr:
		if buff.is_buff:
			buffs.append(BuffInfo.new(buff.type, buff.amount, buff.duration, buff.is_fixed_val))
			remain_SE[Enum.SE.BUFF] += 1
		else:
			debuffs.append(BuffInfo.new(buff.type, buff.amount, buff.duration, buff.is_fixed_val))
			remain_SE[Enum.SE.DEBUFF] += 1
		if buff.is_fixed_val:
			fixed_buff_amounts[buff.type] += buff.amount
		else:
			percent_buff_amounts[buff.type] += buff.amount

func receive_status_effect(se_arr : Array[int]):
	for i in se_arr.size():
		if se_arr[i] != 0:
			match i:
				Enum.SE.GUARD:
					remain_SE[i] = 1
				Enum.SE.BE_GUARDED:
					continue
				_:
					remain_SE[i] += se_arr[i]

func check_guard(unit : StatusController):
	if unit == guard_unit:
		remain_SE[Enum.SE.BE_GUARDED] = 0
		guard_unit = null

func guard_consume():
	remain_SE[Enum.SE.BE_GUARDED] -= 1
	if remain_SE[Enum.SE.BE_GUARDED] == 0:
		guard_unit.remain_SE[Enum.SE.GUARD] = 0
		guard_unit = null

func unit_be_guarded(guard_time : int, _guard_unit : StatusController):
	remain_SE[Enum.SE.GUARD] = 0
	GlobalSignal.emit_signal("guard_broken", self)
	
	if guard_unit == _guard_unit:
		remain_SE[Enum.SE.BE_GUARDED] += guard_time
	else:
		if guard_unit != null:
			guard_unit.remain_SE[Enum.SE.GUARD] = 0
		guard_unit = _guard_unit
		remain_SE[Enum.SE.BE_GUARDED] = guard_time

func riposte():
	remain_SE[Enum.SE.RIPOSTE] -= 1
	
func assist():	
	remain_SE[Enum.SE.ASSIST] -= 1

func end_of_period():
	for i in range(buffs.size() - 1, -1, -1):
		buffs[i].duration -= 1
		if buffs[i].duration == 0:
			if buffs[i].is_fixed_val:
				fixed_buff_amounts[buffs[i].type] -= buffs[i].amount
			else:
				percent_buff_amounts[buffs[i].type] -= buffs[i].amount
			
			remain_SE[Enum.SE.BUFF] -= 1
			buffs.remove_at(i)
	
	for i in range(debuffs.size() - 1, -1, -1):
		debuffs[i].duration -= 1
		if debuffs[i].duration == 0:
			if debuffs[i].is_fixed_val:
				fixed_buff_amounts[debuffs[i].type] -= debuffs[i].amount
			else:
				percent_buff_amounts[debuffs[i].type] -= debuffs[i].amount
			
			remain_SE[Enum.SE.DEBUFF] -= 1
			debuffs.remove_at(i)
	
	manage_se_icons()

func manage_se_icons():
	for i in remain_SE.size():
		if remain_SE[i] == 0:
			status_effects[i].hide()
			continue
		
		var label_text : String
			
		match i:
			Enum.SE.BUFF:
				for j in Enum.Stat.size():
					if fixed_buff_amounts[j] > 0:
						label_text += str(j) + " +" + str(fixed_buff_amounts[j]) + " (" + str(find_longest_duration(j, true, true)) + " turns)\n"
					if percent_buff_amounts[j] > 0:
						label_text += str(j) + " +" + str(percent_buff_amounts[j]) + "% (" + str(find_longest_duration(j, true, false)) + " turns)\n"
			Enum.SE.DEBUFF:
				for j in Enum.Stat.size():
					if fixed_buff_amounts[j] < 0:
						label_text += str(j) + " " + str(fixed_buff_amounts[j]) + " (" + str(find_longest_duration(j, false, true)) + " turns)\n"
					if percent_buff_amounts[j] < 0:
						label_text += str(j) + " " + str(percent_buff_amounts[j]) + "% (" + str(find_longest_duration(j, false, false)) + " turns)\n"
			Enum.SE.GUARD:
				label_text = status_effects[i].name
			Enum.SE.BE_GUARDED:
				if guard_unit == null or guard_unit.remain_SE[Enum.SE.GUARD] == 0:
					remain_SE[i] = 0
					status_effects[i].hide()
					continue
				
				label_text = status_effects[i].name + "by " + guard_unit.unit_name + " (" + str(remain_SE[i]) + " times)"
			_:
				label_text = status_effects[i].name + " (" + str(remain_SE[i]) + " times)"
		
		status_effects[i].tooltip_text = label_text
		status_effects[i].show()

func find_longest_duration(buff_type : int, is_buff : bool, is_fixed : bool) -> int:
	var ret : int = 0
	
	if is_buff:
		for buff in buffs:
			if buff.type == buff_type and buff.duration > ret and buff.is_fixed_val == is_fixed:
				ret = buff.duration
	else:
		for debuff in debuffs:
			if debuff.type == buff_type and debuff.duration > ret and debuff.is_fixed_val == is_fixed:
				ret = debuff.duration
				
	return ret

func dodged():
	play_anim("unit_animation/dodge")
	
	GlobalData.make_status_indicator("Dodged", self.global_position)

func crit_hit():
	GlobalData.make_status_indicator("Crit!", self.global_position)

func passed():
	GlobalData.make_status_indicator("Pass", self.global_position)

func death():
	if guard_unit != null:
		guard_unit.remain_SE[Enum.SE.GUARD] = 0
	GlobalSignal.emit_signal("guard_broken", self)
	GlobalSignal.emit_signal("unit_died", self)
	is_die = true
	play_anim("unit_animation/death")

func exhausted():
	play_anim("unit_animation/exhausted")
	GlobalSignal.emit_signal("guard_broken", self)
	
	for buff in buffs:
		if buff.is_fixed_val:
			fixed_buff_amounts[buff.type] -= buff.amount
		else:
			percent_buff_amounts[buff.type] -= buff.amount
	buffs.clear()
	
	for i in remain_SE.size():
		match i:
			Enum.SE.DEBUFF:
				continue
			Enum.SE.MARKED:
				continue
			Enum.SE.BE_GUARDED:
				continue
			Enum.SE.EXHAUSTED:
				remain_SE[i] = 1
			_:
				remain_SE[i] = 0

func escape_exhaust(amount : int):
	remain_SE[Enum.SE.EXHAUSTED] = 0
	
	if amount == 0:
		remain_energy = unit_stat[Enum.Stat.ENERGY]
	else:
		remain_energy = amount
	
	passed()
	play_anim("unit_animation/idle")

func play_anim(anim_name : String):
	anim_player.play(anim_name)
	anim_player.seek(0)

func on_animation_finished(anim_name : String):
	if anim_name == "unit_animation/death":
		queue_free()

func play_move_motion(motion_pos : Vector2):
	var pos_tween : Tween = create_tween()
	pos_tween.set_trans(Tween.TRANS_CUBIC)
	pos_tween.set_ease(Tween.EASE_OUT)
	pos_tween.tween_property(self, "global_position", motion_pos, 1)
	
func play_pos_motion(motion_pos : Vector2):
	global_position = motion_pos
	
func play_scale_motion(get_big : bool):
	if get_big:
		scale = Vector2(3,3)
	else:
		scale = Vector2(1,1)
		anim_player.play("unit_animation/idle")
