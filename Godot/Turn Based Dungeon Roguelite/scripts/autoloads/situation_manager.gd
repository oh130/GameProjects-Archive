extends Node

const PARAM_USE_SITUATIONS : Array[Enum.Situation] =\
[
	Enum.Situation.CHAPTER_ENTER,
	Enum.Situation.ENCOUNTER_ENTER,
	Enum.Situation.GET_EQUIPMENT,
	Enum.Situation.USE_CONSUMABLE,
	Enum.Situation.CAST,
	Enum.Situation.CRIT_CAST
]

const MUST_SHOW_DIALOG_SITUATIONS : Array[Enum.Situation] =\
[
	Enum.Situation.CHAPTER_ENTER,
	Enum.Situation.GET_EQUIPMENT,
	Enum.Situation.CRIT_CAST,
	Enum.Situation.ENTER_EXHAUST,
	Enum.Situation.ENTER_DEFENSELESS,
	Enum.Situation.ENTER_LUCID,
	Enum.Situation.ENTER_HAZY,
	Enum.Situation.ENTER_FAINT,
	Enum.Situation.ALLY_DEATH,
]

const SITUATION_GET_EXP : Dictionary[Enum.Situation, int] =\
{
	Enum.Situation.AIMED: 1,
	Enum.Situation.HIT: 3,
	Enum.Situation.DODGE: 1,
	Enum.Situation.TURN_PASS: 2,
	Enum.Situation.WEAKNESS_ATTACKED: 1,
	Enum.Situation.COUNTER: 1,
	Enum.Situation.ASSIST: 1,
	Enum.Situation.ENTER_EXHAUST: 2,
	Enum.Situation.ENTER_DEFENSELESS: 2,
	Enum.Situation.ENTER_LUCID: 1,
	Enum.Situation.ENTER_HAZY: 2,
	Enum.Situation.ENTER_FAINT: 3,
	Enum.Situation.MAKE_EXHAUST: 2,
	Enum.Situation.MAKE_DEFENSELESS: 2,
	Enum.Situation.ALLY_DEATH: 5,
	Enum.Situation.EXECUTE: 3,
	Enum.Situation.CRIT_CAST: 1,
}

const FRIENDLY_SKILL_EXP := 4

var on_chapter_choice := false
var on_combat := false
var on_skill_anim := false :
	set(value):
		on_skill_anim = value
		set_deny_input()
		if not value:
			anim_finished.emit()
var on_enemy_turn := false :
	set(value):
		on_enemy_turn = value
		set_deny_input()

var on_reward := false
var on_enh_select := false :
	set(value):
		on_enh_select = value
		if not value:
			enh_select_finished.emit()

var usual_state := false :
	set(value):
		usual_state = value
		if value:
			usual_timer.start()
		else:
			usual_timer.stop()
var already_wait_dialog := false

# usual dialogs.
var usual_timer : Timer
var talked_usual_dialogs : Array[String]
var talked_usual_duo_dialogs : Array[String] # can't repeat.

# situation dialogs.
var timer : Timer
var elapsed_situation : Dictionary[Player, Enum.Situation]
var recent_dialogs : Array[String]

signal anim_finished()
signal enh_select_finished()
signal situation_occured_signal(situation : Enum.Situation)

func _ready():
	timer = Timer.new()
	timer.wait_time = 1
	timer.autostart = false
	timer.one_shot = true
	
	usual_timer = Timer.new()
	usual_timer.wait_time = randi_range(10, 20)
	usual_timer.autostart = false
	usual_timer.one_shot = true
	usual_timer.timeout.connect(usual_dialog)
	
	add_child(timer)
	add_child(usual_timer)

func set_deny_input():
	GameManager.deny_input = on_skill_anim or on_enemy_turn

func refresh_dialog_arrs():
	elapsed_situation.clear()
	recent_dialogs.clear()
	talked_usual_dialogs.clear()
	talked_usual_duo_dialogs.clear()

func occur(situation : Enum.Situation, player : Player, param : Resource = null):
	situation_occured_signal.emit(situation)
	
	# combat exp handling.
	if on_combat:
		if situation in SITUATION_GET_EXP:
			player.combat_accumulated_exp += SITUATION_GET_EXP[situation]
		elif situation == Enum.Situation.CAST:
			if (param as PlayerSkill).is_friendly():
				player.combat_accumulated_exp += FRIENDLY_SKILL_EXP
	
	# handle passives.
	# *NOTE: this passives can be handled by situation(discrete).
	match situation:
		# no param.
		Enum.Situation.COMBAT_FOCUSED:
			pass
		Enum.Situation.COMBAT_ENTER:
			pass
		Enum.Situation.SHOP_ENTER:
			pass
		Enum.Situation.COMBAT_END:
			pass
		Enum.Situation.LEVEL_UP:
			pass
		Enum.Situation.AIMED:
			pass
		Enum.Situation.HIT:
			pass
		Enum.Situation.DODGE:
			pass
		Enum.Situation.TURN_PASS:
			pass
		Enum.Situation.TAKE_FRIENDLY_SKILL:
			pass
		Enum.Situation.ENTER_EXHAUST:
			pass
		Enum.Situation.ENTER_DEFENSELESS:
			pass
		Enum.Situation.ENTER_LUCID:
			pass
		Enum.Situation.ENTER_HAZY:
			pass
		Enum.Situation.ENTER_FAINT:
			pass
		Enum.Situation.DEATH:
			pass
		Enum.Situation.ALLY_DEATH:
			pass
		
		Enum.Situation.TURN_START:
			pass
		Enum.Situation.TURN_END:
			pass
		Enum.Situation.ALLY_ACTED:
			pass
		
		# sometimes need target param.
		Enum.Situation.WEAKNESS_ATTACKED:
			pass
		Enum.Situation.COUNTER:
			pass
		Enum.Situation.ASSIST:
			pass
		Enum.Situation.MAKE_SHIELD_BRAKE:
			pass
		Enum.Situation.MAKE_EXHAUST:
			pass
		Enum.Situation.MAKE_DEFENSELESS:
			pass
		Enum.Situation.EXECUTE:
			pass
		
		# param: chapter.
		Enum.Situation.CHAPTER_ENTER:
			pass
		
		# param: encounter.
		Enum.Situation.ENCOUNTER_ENTER:
			pass
		
		# param: item.
		Enum.Situation.GET_EQUIPMENT:
			pass
		Enum.Situation.USE_CONSUMABLE:
			pass
		
		# param: skill.
		Enum.Situation.CAST:
			pass
		Enum.Situation.CRIT_CAST:
			pass
	
	manage_dialog(situation, player, param)

func manage_dialog(situation : Enum.Situation, player : Player, param : Resource = null):
	if not timer.is_stopped():
		return
	
	# if on skill anim, await and collect all dialog request.
	# if request's priority is heavy, then change to it.
	if elapsed_situation.has(player):
		elapsed_situation[player] = maxi(elapsed_situation[player], situation)
	else:
		elapsed_situation[player] = situation
	
	if already_wait_dialog:
		return
	
	# wait for elapse dialog request.
	already_wait_dialog = true
	if on_skill_anim:
		await anim_finished
	await get_tree().create_timer(0.05).timeout
	
	# compare priority and pick talker.
	var talker : Player
	var temp := -1
	for p in elapsed_situation:
		if p.is_died:
			continue
		
		if temp < elapsed_situation[p]:
			temp = elapsed_situation[p]
			talker = p
	
	if not talker:
		already_wait_dialog = false
		elapsed_situation.clear()
		return
	
	# get dialog str.
	var dialog_str := "%s_%s_" % [talker.data.resource_name, Enum.Situation.keys()[elapsed_situation[talker]]]
	if elapsed_situation[talker] in PARAM_USE_SITUATIONS:
		dialog_str += "%s_" % param.resource_name
	
	# put all dialog in pool.
	var i := 0
	var dialog_pool : Array[String]
	while tr(dialog_str + str(i)) != dialog_str + str(i):
		if recent_dialogs.has(dialog_str + str(i)):
			i += 1
			continue
		
		dialog_pool.append(dialog_str + str(i))
		i += 1
	
	if dialog_pool.is_empty():
		already_wait_dialog = false
		elapsed_situation.clear()
		return
	
	# random dialog.
	if elapsed_situation[talker] in MUST_SHOW_DIALOG_SITUATIONS or randf() < 0.5:
		var picked_dialog : String = dialog_pool.pick_random()
		recent_dialogs.append(picked_dialog)
		if recent_dialogs.size() > 4:
			recent_dialogs.pop_front()
		
		talker.dialog_box.set_dialog(picked_dialog)
		timer.start()
	
	already_wait_dialog = false
	elapsed_situation.clear()

func usual_dialog():
	if not DataManager.run:
		return
	
	if on_chapter_choice:
		return
	
	var players := DataManager.run.players.duplicate()
	var dialog_pool : Array[String]
	var dialog_talker_map : Dictionary[String, Player]
	var dialog_applier_map : Dictionary[String, Player] # only if duo dialog.
	
	for p1 : Player in players:
		var i := 0
		var sol_str := "%s_USUAL_" % p1.data.resource_name
		while tr(sol_str + str(i)) != sol_str + str(i):
			if talked_usual_dialogs.has(sol_str + str(i)):
				i += 1
				continue
			
			dialog_pool.append(sol_str + str(i))
			dialog_talker_map[sol_str + str(i)] = p1
			i += 1
		
		if DataManager.save_data.chapter:
			var chapter_sol_str := "%s_USUAL_%s_" % [p1.data.resource_name, DataManager.save_data.chapter.resource_name]
			var k := 0
			while tr(chapter_sol_str + str(k)) != chapter_sol_str + str(k):
				if talked_usual_dialogs.has(chapter_sol_str + str(k)):
					k += 1
					continue
				
				dialog_pool.append(chapter_sol_str + str(k))
				dialog_talker_map[chapter_sol_str + str(k)] = p1
				k += 1
		
		for p2 : Player in players:
			if p1 == p2:
				continue
			
			var j := 0
			var duo_str := "%s_TO_%s_USUAL_" % [p1.data.resource_name, p2.data.resource_name]
			while tr(duo_str + str(j)) != duo_str + str(j):
				if talked_usual_duo_dialogs.has(duo_str + str(j)):
					j += 1
					continue
				dialog_pool.append(duo_str + str(j))
				dialog_talker_map[duo_str + str(j)] = p1
				dialog_applier_map[duo_str + str(j)] = p2
				j += 1
	
	usual_timer.wait_time = randi_range(10, 20)
	usual_timer.start()
	
	if dialog_pool.is_empty():
		talked_usual_dialogs.clear()
		usual_dialog()
		return
	
	var dialog_str : String = dialog_pool.pick_random()
	var talker := dialog_talker_map[dialog_str]
	var applier : Player = null
	
	# duo dialog.
	if dialog_applier_map.has(dialog_str):
		talked_usual_duo_dialogs.append(dialog_str)
		applier = dialog_applier_map[dialog_str]
	else:
		talked_usual_dialogs.append(dialog_str)
	
	await talker.dialog_box.set_dialog(dialog_str)
	if applier:
		await get_tree().create_timer(0.7).timeout
		await applier.dialog_box.set_dialog("%s_APPLY" % dialog_str)
