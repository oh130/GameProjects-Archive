class_name SkillEffects extends RefCounted
# Class of skill effects with all effects calculated.
# All ratios, equipments, and passives are calculated.

const EXHAUST_REDUCE_DMG := 0.1
const BREAK_ADD_DMG := 0.1
const DEFENSELESS_ADD_DMG := 0.5

# only once applied.
enum Effect
{
	# common
	DMG,
	ENERGY_DMG,
	HEAL,
	GAIN_ENERGY,
	SHIELD,
}

# separately applied per target.
enum TargetEffect
{
	HP_PER_DMG,
	HP_PER_HEAL,
	HP_PER_SHIELD,
	
	LOST_HP_PER_DMG,
}

# special effects that has amount.
# only once applied.
enum AmountEffect
{
	# before cast.
	ADD_REPEAT_TIME_PER_ENERGY_AMOUNT,
}

# separately applied.
enum TargetAmountEffect
{
	DMG_AMP_TO_SHIELD,
	DMG_AMP_PER_EXHAUST,
	DMG_AMP_PER_MARK,
}

# It hasn't amount.
# only once applied.
enum SpecialEffect
{
	# before cast.
	NOT_CONSUME_TURN,
	
	UNABLE_TO_DODGE,
	
	# about aggro.
	MOVE_ALL_AGGRO_TO_SELF, # ONLY self-support skill. get all enemies' aggro.
}

# separately applied.
enum TargetSpecialEffect
{
	MOVE_AGGRO_TO_SELF, # ONLY support skill. if target has aggro, move aggro to self.
	MOVE_AGGRO_TO_TARGET, # ONLY support skill. if self has aggro, move aggro to target.
	GET_TARGET_AGGRO, # ONLY attack skill. get target's aggro.
}

var caster : Unit
var skill : Skill
var is_friendly : bool
var is_counter : bool
var is_assist : bool
var stats : Dictionary[Enum.Stat, int]
var self_effects : Dictionary[SkillEffects.Effect, int]
var self_gain_statuses : Dictionary[Enum.Status, int]
var self_buff : RefinedBuff
var target_effects : Dictionary[SkillEffects.Effect, int]
var target_gain_statuses : Dictionary[Enum.Status, int]
var target_buff : RefinedBuff

# NOTE: only once called(if skill repeat time is 1).
# handle general effects.
func init_skill_general_effects(caster_val : Unit, skill_val : Skill, counter : bool, assist : bool):
	caster = caster_val
	skill = skill_val
	is_friendly = skill.is_friendly()
	is_counter = counter
	is_assist = assist
	stats = caster.get_all_unsigned_stat()
	for key in skill.stat_mods.keys():
		stats[key] += skill.stat_mods[key]
	
	# if hostile: heal, shield, gain energy are for self.
	# else(friendly): they are for target.
	for effect in skill.effects:
		match effect:
			Effect.DMG:
				target_effects[SkillEffects.Effect.DMG] = skill.effects[effect].apply_ratios(stats)
			Effect.ENERGY_DMG:
				target_effects[SkillEffects.Effect.ENERGY_DMG] = skill.effects[effect].apply_ratios(stats)
			Effect.HEAL:
				if is_friendly:
					target_effects[SkillEffects.Effect.HEAL] = skill.effects[effect].apply_ratios(stats)
				else:
					self_effects[SkillEffects.Effect.HEAL] = skill.effects[effect].apply_ratios(stats)
			Effect.GAIN_ENERGY:
				if is_friendly:
					target_effects[SkillEffects.Effect.GAIN_ENERGY] = skill.effects[effect].apply_ratios(stats)
				else:
					self_effects[SkillEffects.Effect.GAIN_ENERGY] = skill.effects[effect].apply_ratios(stats)
			Effect.SHIELD:
				if is_friendly:
					target_effects[SkillEffects.Effect.SHIELD] = skill.effects[effect].apply_ratios(stats)
				else:
					self_effects[SkillEffects.Effect.SHIELD] = skill.effects[effect].apply_ratios(stats)
	
	# effect has amount.
	for effect in skill.amount_effects:
		match effect:
			pass
	
	# effect not has amount.
	for effect in skill.special_effects:
		match effect:
			SpecialEffect.MOVE_ALL_AGGRO_TO_SELF:
				pass
	
	# handle resilience to target.
	for effect in target_effects:
		if effect in [Effect.HEAL, Effect.GAIN_ENERGY, Effect.SHIELD]:
			target_effects[effect] += roundi(target_effects[effect]\
			* caster.get_unsigned_stat(Enum.Stat.RESILIENCE))
	
	# status, buff.
	for key in skill.self_gain_statuses:
		self_gain_statuses[key] = skill.self_gain_statuses[key].apply_ratios(stats)
	for key in skill.target_gain_statuses:
		target_gain_statuses[key] = skill.target_gain_statuses[key].apply_ratios(stats)
	
	if skill.self_buff:
		self_buff = skill.self_buff.create_refind_buff(stats)
	if skill.target_buff:
		target_buff = skill.target_buff.create_refind_buff(stats)
	
	# handling combat exp.
	if caster is Player:
		for key in self_effects:
			(caster as Player).combat_give_dict[key] += self_effects[key]

# NOTE: called target by target, and cast.
# return skill factor.
func cast_to_target(target : Unit):
	if target.is_died:
		return
	
	# why duplicate: effect must different target by target.
	var dup_te := target_effects.duplicate()
	var dup_tgs := target_gain_statuses.duplicate()
	var dup_tb : RefinedBuff = target_buff.create_copy() if target_buff else null
	
	# if hostile: heal, shield, gain energy are for self.
	# else(friendly): they are for target.
	for effect in skill.target_effects:
		match effect:
			TargetEffect.HP_PER_DMG:
				if not dup_te.has(SkillEffects.Effect.DMG):
					dup_te[SkillEffects.Effect.DMG] = 0
				dup_te[SkillEffects.Effect.DMG] +=\
				int(0.01 * skill.target_effects[effect].apply_ratios(stats) * target.get_unsigned_stat(Enum.Stat.MAX_HEALTH))
			TargetEffect.HP_PER_HEAL:
				if not dup_te.has(SkillEffects.Effect.HEAL):
					dup_te[SkillEffects.Effect.HEAL] = 0
				dup_te[SkillEffects.Effect.HEAL] +=\
				int(0.01 * skill.target_effects[effect].apply_ratios(stats) * target.get_unsigned_stat(Enum.Stat.MAX_HEALTH))
			TargetEffect.HP_PER_SHIELD:
				if not dup_te.has(SkillEffects.Effect.SHIELD):
					dup_te[SkillEffects.Effect.SHIELD] = 0
				dup_te[SkillEffects.Effect.SHIELD] +=\
				int(0.01 * skill.target_effects[effect].apply_ratios(stats) * target.get_unsigned_stat(Enum.Stat.MAX_HEALTH))
			
			TargetEffect.LOST_HP_PER_DMG:
				if not dup_te.has(SkillEffects.Effect.DMG):
					dup_te[SkillEffects.Effect.DMG] = 0
				dup_te[SkillEffects.Effect.DMG] +=\
				int(0.01 * skill.target_effects[effect].apply_ratios(stats)\
				* (target.get_unsigned_stat(Enum.Stat.MAX_HEALTH) - target.data.health))
	
	# effect not has amount.
	for effect in skill.special_effects:
		match effect:
			TargetSpecialEffect.MOVE_AGGRO_TO_SELF:
				for enemy : Enemy in DataManager.run.combat.enemies:
					if enemy.cur_single_target and enemy.cur_single_target != caster\
					and enemy.cur_single_target is Player:
						enemy.cur_single_target = caster
			TargetSpecialEffect.MOVE_AGGRO_TO_TARGET:
				pass
			TargetSpecialEffect.GET_TARGET_AGGRO:
				if target.cur_single_target\
				and target.cur_single_target != caster and target.cur_single_target is Player:
					target.cur_single_target = caster
	
	# NOTE: total dmg mul calculate.
	# SUM operation: amount of skill effect.
	# SUM operation(ONLY player): break.
	# MUL operation(ONLY player): attributes, crit mul.
	# MUL operation: caster exhaust, defenseless, target armor.
	var dmg_mul := 1.0
	var energy_dmg_mul := 1.0
	var restore_mul := 1.0
	
	# check crit.
	var is_crit := false
	
	energy_dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.ENERGY_DMG_AMP)
	
	for effect in skill.target_amount_effects:
		match effect:
			TargetAmountEffect.DMG_AMP_TO_SHIELD:
				if target.data.shield > 0:
					dmg_mul += 0.01 * skill.target_amount_effects[effect].apply_ratios(stats)
			TargetAmountEffect.DMG_AMP_PER_EXHAUST:
				dmg_mul += 0.01 * target.cur_status_arr[Enum.Status.EXHAUST] *\
				skill.target_amount_effects[effect].apply_ratios(stats)
			TargetAmountEffect.DMG_AMP_PER_MARK:
				dmg_mul += 0.01 * target.cur_status_arr[Enum.Status.MARKED] *\
				skill.target_amount_effects[effect].apply_ratios(stats)
	
	# ONLY PLAYER: break, attributes, crit mul.
	if caster is Player:
		# calculate break.
		if not is_friendly:
			if is_counter:
				dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.COUNTER_DMG_AMP)
				energy_dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.COUNTER_DMG_AMP)
			elif is_assist:
				dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.ASSIST_DMG_AMP)
				energy_dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.ASSIST_DMG_AMP)
			
			if target.cur_status_arr[Enum.Status.BREAK] > 0:
				dmg_mul += BREAK_ADD_DMG * target.cur_status_arr[Enum.Status.BREAK]
				energy_dmg_mul += BREAK_ADD_DMG * target.cur_status_arr[Enum.Status.BREAK]
			
			# weakness attack.
			if skill.attack_attribute in target.data.weaknesses:
				SituationManager.occur(Enum.Situation.WEAKNESS_ATTACKED, caster)
				
				if not dup_tgs.has(Enum.Status.BREAK):
					dup_tgs[Enum.Status.BREAK] = 0
				dup_tgs[Enum.Status.BREAK] += 1
			
			# attributes.
			match skill.attack_attribute:
				Enum.Attribute.IMPACT:
					dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.IMPACT_AMP)
					energy_dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.IMPACT_AMP)
				Enum.Attribute.SLASH:
					dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.SLASH_AMP)
					energy_dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.SLASH_AMP)
				Enum.Attribute.PIERCE:
					dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.PIERCE_AMP)
					energy_dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.PIERCE_AMP)
				Enum.Attribute.NATURE:
					dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.NATURE_AMP)
					energy_dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.NATURE_AMP)
				Enum.Attribute.ARCANE:
					dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.ARCANE_AMP)
					energy_dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.ARCANE_AMP)
				Enum.Attribute.MYSTIC:
					dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.MYSTIC_AMP)
					energy_dmg_mul += 0.01 * caster.get_unsigned_stat(Enum.Stat.MYSTIC_AMP)
			
			dmg_mul *= 1 + 0.01 * target.data.att_mods[skill.attack_attribute]
			energy_dmg_mul *= 1 + 0.01 * target.data.att_mods[skill.attack_attribute]
		
		# handling crit.
		if SubRandom.roll_chance(stats[Enum.Stat.CRIT]):
			is_crit = true
			if not is_friendly:
				AnimationManager.camera_zoom_force += 1
			SituationManager.occur(Enum.Situation.CRIT_CAST, caster, skill)
			
			dmg_mul *= 0.01 * stats[Enum.Stat.CRIT_MUL]
			energy_dmg_mul *= 0.01 * stats[Enum.Stat.CRIT_MUL]
			restore_mul *= 0.01 * stats[Enum.Stat.CRIT_MUL]
		
		# handling combat exp.
		for key in dup_te:
			(caster as Player).combat_give_dict[key] += dup_te[key]
	
	if caster.cur_status_arr[Enum.Status.EXHAUST] > 0:
		dmg_mul *= 1 - 0.01 * EXHAUST_REDUCE_DMG
		energy_dmg_mul *= 1 - 0.01 * EXHAUST_REDUCE_DMG
	
	if target.cur_status_arr[Enum.Status.DEFENSELESS] > 0:
		dmg_mul *= 1 + 0.01 * DEFENSELESS_ADD_DMG
		energy_dmg_mul += 1 + 0.01 * DEFENSELESS_ADD_DMG
	
	# calculate armor.
	# NOTE: it only handle damage, not energy dmg.
	var target_armor : float = target.get_unsigned_stat(Enum.Stat.ARMOR)\
	* (1 - (0.01 * stats[Enum.Stat.ARMOR_PEN_RATE])) - stats[Enum.Stat.ARMOR_PEN] 
	if target_armor > 0:
		dmg_mul *= (1 / (1 + 0.01 * target_armor))
	
	
	for effect in dup_te:
		if effect in [Effect.HEAL, Effect.GAIN_ENERGY, Effect.SHIELD]:
			dup_te[effect] = roundi(dup_te[effect] * restore_mul)
		elif effect == Effect.DMG:
			dup_te[effect] = roundi(dup_te[effect] * dmg_mul)
		else:
			dup_te[effect] = roundi(dup_te[effect] * energy_dmg_mul)
	
	# check player dodge.
	if not is_friendly and caster is Enemy and not skill.special_effects.has(SpecialEffect.UNABLE_TO_DODGE):
		# dodged.
		if SubRandom.roll_chance(target.get_unsigned_stat(Enum.Stat.DODGE)):
			(target as Player).dodged()
			return
	
	# give all effects to target.
	var is_already_defenseless := (target.cur_status_arr[Enum.Status.DEFENSELESS] > 0)
	var has_shield := target.data.shield > 0
	var exhaust_count := target.cur_status_arr[Enum.Status.EXHAUST]
	
	target.take_effect(dup_te, is_crit)
	target.add_statuses(dup_tgs)
	target.affect_buff(dup_tb)
	
	# handle vfx.
	VfxManager.create_vfx(skill.vfx, target.targetable_icon.global_position)
	
	
	if not is_friendly:
		if caster is Player:
			# enter defenseless status by this skill.
			if not is_already_defenseless and (target.cur_status_arr[Enum.Status.DEFENSELESS] > 0):
				SituationManager.occur(Enum.Situation.MAKE_DEFENSELESS, caster)
			
			# shield brake.
			if has_shield and target.data.shield == 0:
				SituationManager.occur(Enum.Situation.MAKE_SHIELD_BRAKE, caster)
			
			# exhaust.
			if exhaust_count < target.cur_status_arr[Enum.Status.EXHAUST]:
				SituationManager.occur(Enum.Situation.MAKE_EXHAUST, caster)
			
			# execute.
			if target.is_died:
				SituationManager.occur(Enum.Situation.EXECUTE, caster)
		else:
			target.hit()
	
	else:
		if caster is Player:
			SituationManager.occur(Enum.Situation.TAKE_FRIENDLY_SKILL, target)

# NOTE: effect after ONE REPEAT TIME of skill.
# if skill's repeat time is 3, then it is called 3 times.
func after_effect():
	
	## apply muls to self effect.
	#for effect in dup_se:
		#if effect in [Effect.HEAL, Effect.GAIN_ENERGY, Effect.SHIELD]:
			#dup_se[effect] = roundi(dup_se[effect] * restore_mul)
	
	caster.take_effect(self_effects)
	caster.add_statuses(self_gain_statuses)
	caster.affect_buff(self_buff)
