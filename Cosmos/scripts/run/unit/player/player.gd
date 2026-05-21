class_name Player extends Unit

const EXP_MUL := 1.2
const COMBAT_BASE_EXP := 20
const ENCOUNTER_BASE_EXP := 30

const HAZY_STANDARD := 0.6
const FAINT_STANDARD := 0.3

@onready var dialog_box: DialogBox = %DialogBox
@onready var combat_ui: Control = %CombatUI
@onready var stance_icon: TextureRect = %StanceIcon
@onready var exist_state_icon: TextureRect = %ExistStateIcon
@onready var remain_turn_icon: TextureRect = %RemainTurnIcon
@onready var exp_bar: ProgressBar = %ExpBar
@onready var exp_label: Label = %ExpLabel
@onready var level_up_label: Label = %LevelUpLabel
@onready var level_up_anim: AnimationPlayer = %LevelUpAnim

var exist_state : Enum.ExistState : set = set_exist_state
var stance : Enum.Stance : set = set_stance

var has_remain_turn := false : set = set_remain_turn
var targeted_count := 0 : set = set_targeted
var combat_accumulated_exp := 0
var combat_give_dict : Dictionary[SkillEffects.Effect, int]=\
{
	SkillEffects.Effect.DMG : 0,
	SkillEffects.Effect.ENERGY_DMG : 0,
	SkillEffects.Effect.HEAL : 0,
	SkillEffects.Effect.GAIN_ENERGY : 0,
	SkillEffects.Effect.SHIELD : 0,
}
var combat_take_dict : Dictionary[SkillEffects.Effect, int]=\
{
	SkillEffects.Effect.DMG : 0,
	SkillEffects.Effect.ENERGY_DMG : 0,
}

signal awake_level_reached(player : Player)

func _ready():
	super._ready()
	
	exp_bar.value = 0
	exist_state = Enum.ExistState.LUCID
	stance = Enum.Stance.COMMON
	combat_ui.hide()
	level_up_label.hide()

func set_data(unit_data : UnitData):
	super.set_data(unit_data)
	
	exp_bar.value = float(data.cur_exp) / data.cur_exp_for_up
	exp_label.text = "Lv. %d" % get_unsigned_stat(Enum.Stat.LEVEL)
	
	handle_exist_state()

func health_changed(val : int):
	super.health_changed(val)
	
	if is_died:
		return
	
	handle_exist_state()

func combat_start():
	combat_ui.show()

func combat_ended():
	SituationManager.occur(Enum.Situation.COMBAT_END, self)
	
	for key in combat_give_dict:
		match key:
			SkillEffects.Effect.DMG:
				combat_accumulated_exp += int(0.1 * combat_give_dict[key])
			SkillEffects.Effect.ENERGY_DMG:
				combat_accumulated_exp += int(0.2 * combat_give_dict[key])
			SkillEffects.Effect.HEAL:
				combat_accumulated_exp += int(0.5 * combat_give_dict[key])
			SkillEffects.Effect.GAIN_ENERGY:
				combat_accumulated_exp += int(0.5 * combat_give_dict[key])
			SkillEffects.Effect.SHIELD:
				combat_accumulated_exp += int(0.1 * combat_give_dict[key])
		combat_give_dict[key] = 0
	
	for key in combat_take_dict:
		match key:
			SkillEffects.Effect.DMG:
				combat_accumulated_exp += int(0.2 * combat_give_dict[key])
			SkillEffects.Effect.ENERGY_DMG:
				combat_accumulated_exp += int(0.5 * combat_give_dict[key])
		combat_give_dict[key] = 0
	
	var exp_amount := COMBAT_BASE_EXP + combat_accumulated_exp
	combat_accumulated_exp = 0
	
	if DataManager.save_data.current_route == Enum.Route.ENEMY_MORE_EXP:
		exp_amount = roundi(exp_amount * 1.5)
	
	exp_amount = roundi((1 + 0.01 * get_unsigned_stat(Enum.Stat.GAIN_EXP_AMP)) * exp_amount)
	get_exp(exp_amount)
	
	# data.energy += COMMON_ENERGY_REG
	data.shield = 0
	
	is_targetable = false
	targeted_count = 0
	
	#if data.remain_skill_point > 0:
		#show_particle()
	
	erase_all_buff()
	erase_all_status()
	combat_ui.hide()

func turn_start():
	super.turn_start()
	
	if is_died:
		return
	
	data.energy += roundi(SubRandom.get_randf_range(0.1,0.2) * get_unsigned_stat(Enum.Stat.MAX_ENERGY))
	has_remain_turn = true
	
	SituationManager.occur(Enum.Situation.TURN_START, self)

func turn_end():
	SituationManager.occur(Enum.Situation.TURN_END, self)

func death():
	super.death()
	
	SituationManager.occur(Enum.Situation.DEATH, self)
	erase_all_buff()
	erase_all_status()
	has_remain_turn = false
	targeted_count = 0

func set_exist_state(value : Enum.ExistState):
	if exist_state == value:
		return
	
	match exist_state:
		Enum.ExistState.LUCID:
			SituationManager.occur(Enum.Situation.EXIT_LUCID, self)
		Enum.ExistState.HAZY:
			SituationManager.occur(Enum.Situation.EXIT_HAZY, self)
		Enum.ExistState.FAINT:
			SituationManager.occur(Enum.Situation.EXIT_FAINT, self)
	
	exist_state = value
	exist_state_icon.texture = SubInfoLayer.exist_state_icons[value]
	
	match exist_state:
		Enum.ExistState.LUCID:
			SituationManager.occur(Enum.Situation.ENTER_LUCID, self)
		Enum.ExistState.HAZY:
			SituationManager.occur(Enum.Situation.ENTER_HAZY, self)
		Enum.ExistState.FAINT:
			SituationManager.occur(Enum.Situation.ENTER_FAINT, self)

func handle_exist_state():
	if data.health < FAINT_STANDARD * get_unsigned_stat(Enum.Stat.MAX_HEALTH):
		exist_state = Enum.ExistState.FAINT
	elif data.health < HAZY_STANDARD * get_unsigned_stat(Enum.Stat.MAX_HEALTH):
		exist_state = Enum.ExistState.HAZY
	else:
		exist_state = Enum.ExistState.LUCID

func set_stance(value : Enum.Stance):
	stance = value
	
	stance_icon.texture = SubInfoLayer.stance_icons[stance]

func set_remain_turn(value : bool):
	has_remain_turn = value
	
	remain_turn_icon.visible = value

func set_targeted(value : int):
	if targeted_count < value:
		SituationManager.occur(Enum.Situation.AIMED, self)
	
	targeted_count = value
	
	if targeted_count == 0:
		pass

func hit():
	SituationManager.occur(Enum.Situation.HIT, self)
	if cur_status_arr[Enum.Status.OVERBREATHING] > 0:
		change_status(Enum.Status.OVERBREATHING, -cur_status_arr[Enum.Status.OVERBREATHING])

func dodged():
	SituationManager.occur(Enum.Situation.DODGE, self)
	SubInfoLayer.make_indicator({Enum.IndicateType.DODGE : 0} as Dictionary[Enum.IndicateType, int], targetable_icon.global_position)
	change_status(Enum.Status.OVERBREATHING, 1)

func exhaust():
	SituationManager.occur(Enum.Situation.ENTER_EXHAUST, self)
	super.exhaust()

func take_effect(values : Dictionary[SkillEffects.Effect, int], is_crit := false):
	if values.is_empty():
		return
	
	# handle resilience, take dmg stat.
	for effect in values:
		if effect in [SkillEffects.Effect.HEAL, SkillEffects.Effect.GAIN_ENERGY, SkillEffects.Effect.SHIELD]:
			values[effect] += roundi(values[effect] * get_unsigned_stat(Enum.Stat.RESILIENCE))
		else:
			values[effect] += roundi(values[effect] * get_unsigned_stat(Enum.Stat.TAKE_DMG_AMP))
	
	### why override: this thing ###
	if SituationManager.on_combat:
		for key in values:
			if combat_take_dict.has(key):
				combat_take_dict[key] += values[key]
	################################
	
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

func get_exp(amount : int):
	data.cur_exp += amount
	
	var flag := false
	while data.cur_exp >= data.cur_exp_for_up:
		level_up()
		if get_unsigned_stat(Enum.Stat.LEVEL) % 5 == 0:
			flag = true
	
	exp_bar.value = float(data.cur_exp) / data.cur_exp_for_up
	
	# flag is true = entered awake level.
	if flag:
		if SituationManager.on_enh_select:
			await SituationManager.enh_select_finished
		SituationManager.on_enh_select = true
		awake_level_reached.emit(self)

func level_up():
	SituationManager.occur(Enum.Situation.LEVEL_UP, self)
	level_up_anim.play("level_up")
	
	data.cur_exp -= data.cur_exp_for_up
	data.cur_exp_for_up = int(data.cur_exp_for_up * EXP_MUL)
	
	for stat in data.stat_up_per_level:
		data.stats[stat].amount += data.stat_up_per_level[stat]
	
	# MUST COME OUT AHEAD get_unsigned_stat().
	# because get_unsigned_stat() uses applied stats.
	set_applied_stats()
	
	exp_label.text = "Lv. %d" % get_unsigned_stat(Enum.Stat.LEVEL)

func add_equipment(equipment : Equipment):
	# handle equipment list.
	var flag := false
	for eq : Equipment in data.equipments:
		if eq.resource_name == equipment.resource_name:
			data.equipments[eq] += 1
			
			#handle common eq.
			if eq.resource_name == Pool.COMMON_EQ_NAME:
				for stat in equipment.stats:
					if eq.stats.has(stat):
						eq.stats[stat].add(equipment.stats[stat])
					else:
						eq.stats[stat] = equipment.stats[stat]
					
					if eq.stats[stat].check_zero():
						eq.stats.erase(stat)
			
			flag = true
			break
	
	if not flag:
		data.equipments[equipment] = 1
	
	# append stats.
	sum_dict(data.stats, equipment.stats)
	sum_dict(DataManager.save_data.party_stats, equipment.party_stats)
	
	# append passives.
	for p in equipment.passives:
		data.passives.append(p.duplicate())
	
	set_applied_stats()
	Audio.play_sfx(Audio.equip)

func get_enhancement(enh : Enhancement):
	enh.selected = true
	
	# not skill enhancement.
	if not enh.is_skill_enhancement():
		sum_dict(data.stats, enh.stats)
		for p in enh.passives:
			data.passives.append(p.duplicate())
		
		return
	
	# skill enhancement.
	var skill : PlayerSkill = data.skills[enh.skill_idx]
	var enhance : SkillEnhancement = skill.enhancement
	enhance.selected = true
	
	skill.repeat_time += enhance.repeat_time
	
	# dict add.
	sum_dict(skill.costs, enhance.costs)
	sum_dict(skill.self_conditions, enhance.self_conditions)
	sum_dict(skill.target_conditions, enhance.target_conditions)
	sum_dict(skill.self_gain_statuses, enhance.self_gain_statuses)
	sum_dict(skill.target_gain_statuses, enhance.target_gain_statuses)
	sum_dict(skill.effects, enhance.effects)
	sum_dict(skill.target_effects, enhance.target_effects)
	sum_dict(skill.amount_effects, enhance.amount_effects)
	sum_dict(skill.target_amount_effects, enhance.target_amount_effects)
	
	# array add.
	skill.special_effects.append_array(enhance.special_effects)
	skill.target_special_effects.append_array(enhance.target_special_effects)
	
	# buff: dicts add.
	sum_dict(skill.self_buff.stat_buffs, enhance.self_buff.stat_buffs)
	sum_dict(skill.target_buff.stat_buffs, enhance.target_buff.stat_buffs)

func sum_dict(dict : Dictionary, add_dict : Dictionary) -> Dictionary:
	for key in add_dict:
		if not dict.has(key):
			dict[key] = add_dict[key]
		else:
			if dict[key] is Amount:
				(dict[key] as Amount).add(add_dict[key])
			else:
				dict[key] += add_dict[key]
	
	return dict
