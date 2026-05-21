extends CanvasLayer

const POP_UP_SCENE := preload("res://scenes/ui/pop_up.tscn")
const INDICATOR_SCENE := preload("res://scenes/run/indicator.tscn")

const EFFECT_COLOR_MAP : Dictionary[SkillEffects.Effect, String]=\
{
	SkillEffects.Effect.DMG: "red",
	SkillEffects.Effect.ENERGY_DMG: "yellow",
	SkillEffects.Effect.HEAL: "green",
	SkillEffects.Effect.GAIN_ENERGY: "yellowgreen",
	SkillEffects.Effect.SHIELD: "skyblue"
}

@onready var indicators: Control = %Indicators

@onready var item_tooltip_box: PanelContainer = %ItemTooltipBox
@onready var item_id_label: RichTextLabel = %ItemIDLabel
@onready var item_desc_label: RichTextLabel = %ItemDescLabel

@onready var skill_tooltip_box: PanelContainer = %SkillTooltipBox
@onready var name_label: RichTextLabel = %NameLabel
@onready var att_label: RichTextLabel = %AttLabel
@onready var target_label: RichTextLabel = %TargetLabel
@onready var info_label: RichTextLabel = %InfoLabel
@onready var self_effect_label: RichTextLabel = %SelfEffectLabel
@onready var target_effect_label: RichTextLabel = %TargetEffectLabel
@onready var special_effect_label: RichTextLabel = %SpecialEffectLabel

@onready var status_tooltip_box: PanelContainer = %StatusTooltipBox
@onready var status_id_label: RichTextLabel = %StatusIDLabel
@onready var status_desc_label: RichTextLabel = %StatusDescLabel

@onready var enhancement_tooltip_box: PanelContainer = %EnhancementTooltipBox
@onready var enhancement_id_label: RichTextLabel = %EnhancementIDLabel
@onready var enhancement_desc_label: RichTextLabel = %EnhancementDescLabel

@onready var ability_tooltip_box: PanelContainer = %AbilityTooltipBox
@onready var ability_desc_label: RichTextLabel = %AbilityDescLabel

@export_group("Default Infoes")
@export var def_counter : PlayerSkill
@export var def_assist : PlayerSkill

@export_group("Icon Container")
@export var exist_state_icons : Dictionary[Enum.ExistState, Texture2D] =\
{
	Enum.ExistState.LUCID: null,
	Enum.ExistState.HAZY: null,
	Enum.ExistState.FAINT: null
}
@export var stance_icons : Dictionary[Enum.Stance, Texture2D] =\
{
	Enum.Stance.COMMON: null,
	Enum.Stance.COUNTER: null,
	Enum.Stance.ASSIST: null,
}
@export var stat_icons : Dictionary[Enum.Stat, Texture2D] =\
{
	Enum.Stat.LEVEL: null,
	Enum.Stat.POWER: null,
	Enum.Stat.MAX_HEALTH: null,
	Enum.Stat.MAX_ENERGY: null,
	Enum.Stat.STRENGTH: null,
	Enum.Stat.INTELLIGENCE: null,
	Enum.Stat.DEXTERITY: null,
	Enum.Stat.FAITH: null,
	Enum.Stat.CRIT: null,
	Enum.Stat.CRIT_MUL: null,
	Enum.Stat.ARMOR: null,
	Enum.Stat.DODGE: null,
	Enum.Stat.ARMOR_PEN: null,
	Enum.Stat.ARMOR_PEN_RATE: null,
}
@export var status_icons : Dictionary[Enum.Status, Texture2D] =\
{
	Enum.Status.BREAK: null,
	Enum.Status.DEFENSELESS: null,
	Enum.Status.RIFT: null,
	Enum.Status.MEND: null,
	Enum.Status.EXHAUST: null,
	Enum.Status.OVERBREATHING: null,
	Enum.Status.MARKED: null,
	Enum.Status.STEALTH: null,
}

func _ready():
	item_tooltip_box.reset_size()
	skill_tooltip_box.reset_size()
	status_tooltip_box.reset_size()
	enhancement_tooltip_box.reset_size()
	ability_tooltip_box.reset_size()
	item_tooltip_box.hide()
	skill_tooltip_box.hide()
	status_tooltip_box.hide()
	enhancement_tooltip_box.hide()
	ability_tooltip_box.hide()

func show_item_tooltip(item_ui : ItemUI):
	var data := item_ui.data
	var desc_text := ""
	item_id_label.text = "[b]%s[/b]" % tr(data.resource_name)
	
	if data is Equipment:
		for stat in data.stats:
			desc_text += "%s %s\n" % [get_stat_icon(stat), str_to_signed_str(get_amount_str(data.stats[stat]))]
		
		for stat in data.party_stats:
			desc_text += "%s %+d\n" % [tr(Enum.PartyStat.keys()[stat]), data.party_stats[stat]]
		
		for p in data.passives:
			desc_text += tr(Passive.ID.keys()[p.id])
		
		#if not data.passives.is_empty():
			#desc_text += "[font_size=15][b]%s[/b][/font_size]\n" % tr("SPECIAL_EFFECTS")
			#for key in data.passives:
				#desc_text += "%s %s\n" % [tr(Enum.Passive.keys()[key]), get_amount_str(data.passives[key])]
	
	else:
		desc_text = tr(data.resource_name + "_EFFECT")
		
		if item_ui.loc == ItemUI.Location.INVENTORY:
			if (data.area == Consumable.Area.ALWAYS\
			or (data.area == Consumable.Area.ON_COMBAT and SituationManager.on_combat)\
			or (data.area == Consumable.Area.EXCEPT_COMBAT and not SituationManager.on_combat)):
				desc_text += "\n" + tr("LEFT_CLICK_TO_USE")
			
			if DataManager.run.shop.shop_opened:
				desc_text += "\n%s (+%s)" % [tr("RIGHT_CLICK_TO_SELL"),\
				str(int(Shop.CONSUMABLE_PRICE * Shop.BASE_REFUND_MUL))]
	
	item_desc_label.text = desc_text
	
	### UI Handling ###
	await get_tree().physics_frame
	item_tooltip_box.reset_size()
	item_tooltip_box.position = item_ui.global_position + Vector2(-item_tooltip_box.size.x, 0)
	item_tooltip_box.show()

# why don't pass skill_ui as parameter: enemy intent use this too.
func show_skill_tooltip(skill : Skill, ui_pos : Vector2):
	### Skill Name, Type, Attribute, Target ###
	name_label.text = tr(skill.resource_name)
	
	if skill is PlayerSkill and not skill.is_friendly():
		att_label.text = tr(Enum.Attribute.keys()[skill.attack_attribute])
		att_label.show()
	else:
		att_label.hide()
	
	if skill.is_friendly():
		name_label.text = get_color_str(name_label.text, "green")
	else:
		name_label.text = get_color_str(name_label.text, "red")
	
	target_label.text = tr(Skill.Target.keys()[skill.target])
	
	### Skill Info ###
	var info_text := ""
	if not skill.costs.is_empty():
		for cost in skill.costs:
			info_text += "%s %d," % [tr(Skill.Cost.keys()[cost]), skill.costs[cost]]
		info_text[info_text.length() - 1] = "\n"
	if not skill.self_conditions.is_empty() or not skill.target_conditions.is_empty():
		if not skill.self_conditions.is_empty():
			for cond in skill.self_conditions:
				info_text += "%s %d," % [tr(Skill.Condition.keys()[cond]), skill.self_conditions[cond]]
		if not skill.target_conditions.is_empty():
			for cond in skill.target_conditions:
				info_text += "%s %d," % [tr(Skill.Condition.keys()[cond]), skill.target_conditions[cond]]
		info_text[info_text.length() - 1] = "\n"
	
	var flag := false
	for stat in skill.stat_mods:
		var val : int = skill.stat_mods[stat]
		if val != 0:
			if not flag:
				flag = true
				info_text += "%s: " % tr("STAT_MOD")
			info_text += "%s %+d," % [get_stat_icon(stat), val]
	if flag:
		info_text[info_text.length() - 1] = "\n"
	
	info_label.text = info_text
	
	### Skill Descriptions ###
	var self_text := ""
	var target_text := ""
	var special_effect_text := ""
	var effect_string_str : Array[String]
	effect_string_str.resize(SkillEffects.Effect.size())

	for effect in skill.effects:
		if effect_string_str[effect] != "":
			effect_string_str[effect] += " + %s" % get_amount_str(skill.effects[effect])
		else:
			effect_string_str[effect] += get_amount_str(skill.effects[effect])
	
	for effect in skill.target_effects:
		# change target effect to effect.
		var idx := get_effect_of_target_effect(effect)
		
		if effect_string_str[idx] != "":
			effect_string_str[idx] +=\
			" + %s %s%%" % [tr("MAX_HEALTH_OF_TARGET"), get_amount_str(skill.target_effects[effect])]
		else:
			effect_string_str[idx] +=\
			"%s %s%%" % [tr("MAX_HEALTH_OF_TARGET"), get_amount_str(skill.target_effects[effect])]
	
	for i in SkillEffects.Effect.size():
		if effect_string_str[i] == "":
			continue
		
		var effect_string := get_color_str("%s: %s\n" % [tr(SkillEffects.Effect.keys()[i]), effect_string_str[i]], EFFECT_COLOR_MAP[i])
		
		if skill.target == Skill.Target.SELF or (not skill.is_friendly()\
		and not i in [SkillEffects.Effect.DMG, SkillEffects.Effect.ENERGY_DMG]):
			self_text += effect_string
		else:
			target_text += effect_string
	
	if skill.self_buff or not skill.self_gain_statuses.is_empty():
		self_text += "%s: " % tr("GAIN")
		if skill.self_buff:
			for stat in skill.self_buff.stat_buffs:
				self_text += "%s%s," % [get_stat_icon(stat), get_amount_str(skill.self_buff.stat_buffs[stat])]
		if not skill.self_gain_statuses.is_empty():
			for status in skill.self_gain_statuses:
				self_text += "%s%s," % [get_status_icon(status), get_amount_str(skill.self_gain_statuses[status])]
		self_text[self_text.length() - 1] = "\n"
	
	if skill.target_buff or not skill.target_gain_statuses.is_empty():
		target_text += "%s: " % tr("GAIN")
		if skill.target_buff:
			for stat in skill.target_buff.stat_buffs:
				target_text += "%s%s," % [get_stat_icon(stat), get_amount_str(skill.target_buff.stat_buffs[stat])]
		if not skill.target_gain_statuses.is_empty():
			for status in skill.target_gain_statuses:
				target_text += "%s%s," % [get_status_icon(status), get_amount_str(skill.target_gain_statuses[status])]
		target_text[target_text.length() - 1] = "\n"
	
	### Set all labels ###
	for spe in skill.special_effects:
		special_effect_text += "%s\n" % tr(SkillEffects.SpecialEffect.keys()[spe])
	
	self_effect_label.visible = (self_text != "")
	if self_text != "":
		self_effect_label.text = "[font_size=15][b]%s[/b][/font_size]\n%s" % [tr("SELF"), self_text]
	
	target_effect_label.visible = (target_text != "")
	if target_text != "":
		target_effect_label.text = "[font_size=15][b]%s[/b][/font_size]\n%s" % [tr("TARGET"), target_text]
	
	special_effect_label.visible = (special_effect_text != "")
	if special_effect_text != "":
		special_effect_label.text = "[font_size=15][b]%s[/b][/font_size]\n%s" % [tr("SPECIAL_EFFECTS"), special_effect_text]
	
	### UI Handling ###
	await get_tree().physics_frame
	skill_tooltip_box.reset_size()
	skill_tooltip_box.position = ui_pos + Vector2(-skill_tooltip_box.size.x, 0)
	skill_tooltip_box.show()

func show_status_tooltip(id_str : String, desc_str : String, pos : Vector2):
	status_id_label.text = id_str
	status_desc_label.text = desc_str
	
	await get_tree().physics_frame
	status_tooltip_box.reset_size()
	status_tooltip_box.position = pos + Vector2(-status_tooltip_box.size.x, 0)
	status_tooltip_box.show()

func show_enhancement_tooltip(enhancement_ui : EnhancementUI):
	var enhancement_id := enhancement_ui.data.resource_name
	enhancement_id_label.text = "[b]%s[/b]" % tr(enhancement_id)
	enhancement_desc_label.text = tr(enhancement_id + "_DESC")
	
	await get_tree().physics_frame
	enhancement_tooltip_box.reset_size()
	enhancement_tooltip_box.position =\
	enhancement_ui.global_position + Vector2(-enhancement_tooltip_box.size.x, 0)
	enhancement_tooltip_box.show()

func show_ability_tooltip(abilities : Array[Passive], pos : Vector2):
	ability_desc_label.text = ""
	for p in abilities:
		ability_desc_label.text += "%s\n" % get_passive_str(p)
	
	await get_tree().physics_frame
	ability_tooltip_box.reset_size()
	ability_tooltip_box.position = pos + Vector2(-ability_tooltip_box.size.x, 0)
	ability_tooltip_box.show()

func hide_item_tooltip():
	item_tooltip_box.hide()

func hide_skill_tooltip():
	skill_tooltip_box.hide()

func hide_status_tooltip():
	status_tooltip_box.hide()

func hide_enhancement_tooltip():
	enhancement_tooltip_box.hide()

func hide_ability_tooltip():
	ability_tooltip_box.hide()

func get_stat_icon(stat : Enum.Stat) -> String:
	if not stat_icons.has(stat):
		return tr(Enum.Stat.keys()[stat])
	return "[img=20]%s[/img]" % stat_icons[stat].resource_path

func get_status_icon(status : Enum.Status) -> String:
	return "[img=20]%s[/img]" % status_icons[status].resource_path

func get_color_str(target_str : String, color : String) -> String:
	return "[color=%s]%s[/color]" % [color, target_str]

func str_to_signed_str(val : String) -> String:
	if val[0] == "-":
		return val
	else:
		return "+" + val

func get_amount_str(amount : Amount) -> String:
	var ret := ""
	var first_flag := true
	if amount.amount != 0:
		ret += "%s" % str(amount.amount)
		first_flag = false
	for key in amount.ratios:
		if first_flag:
			first_flag = false
			ret += ("%s%s" % [str(amount.ratios[key]), get_stat_icon(key)])
		else:
			ret += ("+%s%s" % [str(amount.ratios[key]), get_stat_icon(key)])
	
	if amount.amount != 0 and not amount.ratios.is_empty():
		ret = "(%s)" % ret
	return ret

func get_buff_str(buff : Buff) -> String:
	var ret := ""
	
	for key in buff.stat_buffs:
		if ret != "":
			ret += ", "
		ret += "%s %s" % [tr(Enum.Stat.keys()[key]), str_to_signed_str(get_amount_str(buff.stat_buffs[key]))]
	
	if buff.temp_buff_end_timing != Enum.Situation.NONE:
		ret += " (%s : %s)" % [tr("END"), tr(Enum.Situation.keys()[buff.temp_buff_end_timing])]
	
	return ret

func get_passive_str(passive : Passive) -> String:
	var ret := ""
	
	if passive is BuffPassive:
		ret += "%s %s: %s" % [tr("BUFF AT"),\
		tr(Enum.Situation.keys()[passive.effect_timing]), get_buff_str(passive.buff)]
	else:
		ret += "%s" % tr(Passive.ID.keys()[passive.id])
	
	return ret

func get_float_str(val : float) -> String:
	if is_equal_approx(val, roundf(val)):
		return str(roundi(val))
	else:
		return str(val)

func get_effect_of_target_effect(val : SkillEffects.TargetEffect) -> SkillEffects.Effect:
	var ret : SkillEffects.Effect
	match val:
		SkillEffects.TargetEffect.HP_PER_DMG:
			ret = SkillEffects.Effect.DMG
		SkillEffects.TargetEffect.HP_PER_HEAL:
			ret = SkillEffects.Effect.HEAL
		SkillEffects.TargetEffect.HP_PER_SHIELD:
			ret = SkillEffects.Effect.SHIELD
		SkillEffects.TargetEffect.LOST_HP_PER_DMG:
			ret = SkillEffects.Effect.DMG
	
	return ret

func make_indicator(indicator_dict : Dictionary[Enum.IndicateType, int], pos : Vector2):
	if indicator_dict.is_empty():
		return
	
	var indicator := INDICATOR_SCENE.instantiate()
	indicators.add_child(indicator)
	indicator.set_indicator(indicator_dict, pos)

func make_popup(des : String, conf_c : Callable):
	var pop_up := POP_UP_SCENE.instantiate()
	add_child(pop_up)
	pop_up.set_popup(des, conf_c)
