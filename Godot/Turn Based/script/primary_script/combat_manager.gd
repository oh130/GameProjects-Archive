extends Node

# static
@onready var player_group = $"../PlayerGroup"
@onready var enemy_group = $"../EnemyGroup"

@onready var player_positions = $"../PlayerGroup".get_child(1).get_children()
@onready var enemy_positions = $"../EnemyGroup".get_child(1).get_children()
@onready var player_turnmarks = $"../PlayerGroup".get_child(2).get_children()
@onready var enemy_turnmarks = $"../EnemyGroup".get_child(2).get_children()
@onready var player_highlights = $"../PlayerGroup".get_child(3).get_children()
@onready var enemy_highlights = $"../EnemyGroup".get_child(3).get_children()
@onready var player_targeted = $"../PlayerGroup".get_child(4).get_children()
@onready var enemy_targeted = $"../EnemyGroup".get_child(4).get_children()
@onready var player_click_areas = $"../PlayerGroup".get_child(5).get_children()
@onready var enemy_click_areas = $"../EnemyGroup".get_child(5).get_children()

@onready var player_motion_pos = $"../PlayerMotionPos".get_children()
@onready var enemy_motion_pos = $"../EnemyMotionPos".get_children()

@onready var combat_ui = $"../CombatUI"

@onready var skill_ui = $"../CombatUI/SkillUI"
@onready var skill_buttons = $"../CombatUI/SkillUI/Skills".get_children()
@onready var move_button = $"../CombatUI/SkillUI/Move"

@onready var player_ui = $"../CombatUI/PlayerInfoUI"
@onready var player_portrait = $"../CombatUI/PlayerInfoUI/PlayerPortrait"
@onready var player_name = $"../CombatUI/PlayerInfoUI/PlayerName"
@onready var player_stat_texts = $"../CombatUI/PlayerInfoUI/PlayerStatTexts".get_children()
@onready var player_item_list = $"../CombatUI/PlayerInfoUI/PlayerItemList"

@onready var enemy_ui = $"../CombatUI/EnemyInfoUI"
@onready var enemy_portrait = $"../CombatUI/EnemyInfoUI/EnemyPortrait"
@onready var enemy_name = $"../CombatUI/EnemyInfoUI/EnemyName"
@onready var enemy_stat_texts = $"../CombatUI/EnemyInfoUI/EnemyStatTexts".get_children()
@onready var enemy_item_list = $"../CombatUI/EnemyInfoUI/EnemyItemList"

@onready var turn_checker = $"../CombatUI/TurnUI/TurnChecker"
@onready var turn_list = $"../CombatUI/TurnUI/TurnList"

# packed scenes
@export var item_pop_up : PackedScene
@export var result_pop_up : PackedScene

# variables
var combat_units : Array[StatusController]
var current_turn_unit : StatusController
var selected_skill : Dictionary
var turn_process_array : Array[TurnData]

var cur_skill_target : String
var cur_skill_is_friendly : bool
var cur_skill_is_wide : bool

var players : Array[Node]
var enemies : Array[Node]

var player_exist_in : Array[bool] = [false, false, false, false]
var enemy_exist_in : Array[bool] = [false, false, false, false]

var is_combat_finished : bool = false

func _ready():
	connect_signals()

func connect_signals():
	GlobalSignal.unit_died.connect(unit_removed)
	
	for i in skill_buttons.size():
		skill_buttons[i].toggled.connect(on_skill_toggled.bind(i))
		
	for i in player_click_areas.size():
		player_click_areas[i].mouse_entered.connect(on_mouse_entered_unit.bind(i, false))
		player_click_areas[i].mouse_exited.connect(on_mouse_exited_unit.bind(i, false))
		player_click_areas[i].input_event.connect(on_mouse_clicked_unit.bind(i, false))
		
	for i in enemy_click_areas.size():
		enemy_click_areas[i].mouse_entered.connect(on_mouse_entered_unit.bind(i, true))
		enemy_click_areas[i].mouse_exited.connect(on_mouse_exited_unit.bind(i, true))
		enemy_click_areas[i].input_event.connect(on_mouse_clicked_unit.bind(i, true))

func combat_confront():
	combat_ui.show()
	skill_ui.hide()
	player_ui.hide()
	enemy_ui.hide()
	
	players = player_group.get_child(0).get_children()
	enemies = enemy_group.get_child(0).get_children()
	
	combat_units.append_array(players)
	combat_units.append_array(enemies)
	
	for p in players:
		player_exist_in[p.combat_pos] = true
	
	for e in enemies:
		enemy_exist_in[e.combat_pos] = true
	
	period_process()

func period_process():
	turn_checker.text = str(int(turn_checker.text) + 1)
	
	for unit in combat_units:
		for i in unit.given_turn:
			var turn_data : TurnData = TurnData.new(unit.get_stat(Enum.Stat.SPEED) + randi_range(0,6), unit)
			turn_process_array.append(turn_data)
	
	turn_process_array.sort_custom(func(a : TurnData, b : TurnData) : return a.mod_speed > b.mod_speed)
	
	for td in turn_process_array:
		var _portrait : TextureRect = GlobalData.turn_list_portrait.instantiate()
		_portrait.portrait_create(td.unit)
		turn_list.add_child(_portrait)
	
	turn_list.period_start()
	
	turn_start(true)

func turn_start(is_first_turn : bool):
	if not is_first_turn:
		await turn_list.proceed_turn()
	
	current_turn_unit = turn_process_array.pop_front().unit
	
	if current_turn_unit.is_enemy:
		enemy_turnmarks[current_turn_unit.combat_pos].show()
		manage_enemy_ui(current_turn_unit)
		if current_turn_unit.remain_SE[Enum.SE.EXHAUSTED]:
			current_turn_unit.escape_exhaust(0)
			turn_end()
		else:
			enemy_ai_act()
		return
	
	player_turnmarks[current_turn_unit.combat_pos].show()
	manage_player_ui(current_turn_unit)
	if current_turn_unit.remain_SE[Enum.SE.EXHAUSTED]:
		current_turn_unit.escape_exhaust(0)
		turn_end()
		return
		
	manage_player_skill_buttons()

func manage_player_skill_buttons():
	skill_ui.show()
	
	var idx : int = 0	
	for skill in GlobalData.unit_skills[current_turn_unit.unit_name]:
		var launch : String = skill["launch"]
		var pos : String = str(current_turn_unit.combat_pos)
		var target : String = skill["target"]
		var cost : Dictionary = skill["cost"]
		var button_disabled : bool = false
		
		for co in cost.keys():
			match co:
				"health":
					if current_turn_unit.remain_health <= cost[co] as int:
						button_disabled = true
				"health_per":
					if (current_turn_unit.remain_health as float / current_turn_unit.get_stat(Enum.Stat.HEALTH)) <= 0.01 * cost[co] as int:
						button_disabled = true
				"energy":
					if current_turn_unit.remain_energy < cost[co] as int:
						button_disabled = true
				"concentration":
					if current_turn_unit.remain_SE[Enum.SE.CONCENTRATION] < cost[co] as int:
						button_disabled = true
		
		if not (pos in launch and not get_targetable_pos_string(target).is_empty()):
			button_disabled = true
			
		skill_buttons[idx].disabled = button_disabled
		idx += 1

func get_targetable_pos_string(_target : String) -> String:
	if "self" in _target:
		return str(current_turn_unit.combat_pos)
	if "side" in _target:
		if current_turn_unit.combat_pos % 2 == 0:
			return str(current_turn_unit.combat_pos + 1)
		else:
			return str(current_turn_unit.combat_pos - 1)
	
	var able_pos : String
	
	if "other" in _target:
		if current_turn_unit.is_enemy:
			for player in players:
				if player.combat_pos != current_turn_unit.combat_pos:
					able_pos += str(player.combat_pos)
		else:
			for enemy in enemies:
				if enemy.combat_pos != current_turn_unit.combat_pos:
					able_pos += str(enemy.combat_pos)
		return able_pos
	
	var is_friendly : bool = '@' in _target
	var is_straight : bool = '^' in _target
	var is_diagonal : bool = '/' in _target
	
	if (current_turn_unit.is_enemy and not is_friendly) or (not current_turn_unit.is_enemy and is_friendly):
		for player in players:
			if str(player.combat_pos) in _target:
				if is_straight:
					if current_turn_unit.combat_pos % 2 == player.combat_pos % 2:
						able_pos += str(player.combat_pos)
				elif is_diagonal:
					if (current_turn_unit.combat_pos + 1) % 2 == player.combat_pos % 2:
						able_pos += str(player.combat_pos)
				else:
					able_pos += str(player.combat_pos)
	else:
		for enemy in enemies:
			if str(enemy.combat_pos) in _target:
				if is_straight:
					if current_turn_unit.combat_pos % 2 == enemy.combat_pos % 2:
						able_pos += str(enemy.combat_pos)
				elif is_diagonal:
					if (current_turn_unit.combat_pos + 1) % 2 == enemy.combat_pos % 2:
						able_pos += str(enemy.combat_pos)
				else:
					able_pos += str(enemy.combat_pos)
	
	return able_pos

func player_skill_selected(skill_idx : int):
	selected_skill = GlobalData.unit_skills[current_turn_unit.unit_name][skill_idx]
	cur_skill_target = get_targetable_pos_string(selected_skill["target"])
	cur_skill_is_friendly = '@' in selected_skill["target"]
	cur_skill_is_wide = '&' in selected_skill["target"]
	
	if cur_skill_is_friendly:
		for player in players:
			if str(player.combat_pos) in cur_skill_target:
				player_highlights[player.combat_pos].show()	
	else:
		for enemy in enemies:
			if str(enemy.combat_pos) in cur_skill_target:
				enemy_highlights[enemy.combat_pos].show()

func move_selected():
	selected_skill = GlobalData.move_skill
	cur_skill_target = get_targetable_pos_string(selected_skill["target"])

	for highlight in player_highlights:
		highlight.show()

func reset_all_unit_motion():
	for unit in combat_units:
		if unit != null and not unit.is_die:
			if unit.is_enemy:
				unit.play_pos_motion(enemy_positions[unit.combat_pos].global_position)
			else:
				unit.play_pos_motion(player_positions[unit.combat_pos].global_position)
			unit.play_scale_motion(false)

func cast_skill_to(cast_unit : StatusController, target_units : Array[StatusController], skill : Dictionary, riposte : bool, assist : bool):
	var cost : Dictionary = skill["cost"]
	var effects : Dictionary = skill["effects"]
	
	for co in cost.keys():
		match co:
			"health":
				cast_unit.damage_health(cost[co] as int)
			"health_per":
				cast_unit.damage_health((0.01 * cost[co] * cast_unit.get_stat(Enum.Stat.HEALTH)) as int)
			"energy":
				cast_unit.damage_energy(cost[co] as int)
			"concentration":
				cast_unit.remain_SE[Enum.SE.CONCENTRATION] -= cost[co] as int
	
	var cur_unit_stat : Array[int]
	for i in Enum.Stat.size():
		cur_unit_stat.append(cast_unit.get_stat(i))
	
	var dmg_arr : Array[int] = [0,0,0,0]
	var self_buff_arr : Array[BuffInfo]
	var target_buff_arr : Array[BuffInfo]
	var self_se_arr : Array[int]
	var target_se_arr : Array[int]
	self_se_arr.resize(Enum.SE.size())
	target_se_arr.resize(Enum.SE.size())
	var move_arr : Array[MoveData]
	
	var target_move_forward_skill : bool
	var target_move_backward_skill : bool
	
	var unable_to_dodge : bool
	
	for effect_id in effects.keys():
		match effect_id:
			"ranged":
				pass
			"energy_base_dmg":
				dmg_arr[Enum.DmgType.EG] += effects[effect_id] as int
			"energy_dmg_ad_ratio":
				dmg_arr[Enum.DmgType.EG] += (cur_unit_stat[Enum.Stat.AD] * effects[effect_id]) as int
			"energy_dmg_ap_ratio":
				dmg_arr[Enum.DmgType.EG] += (cur_unit_stat[Enum.Stat.AP] * effects[effect_id]) as int
			"ad_base_dmg":
				dmg_arr[Enum.DmgType.AD] += effects[effect_id] as int
			"ad_dmg_ad_ratio":
				dmg_arr[Enum.DmgType.AD] += (cur_unit_stat[Enum.Stat.AD] * effects[effect_id]) as int
			"ad_dmg_ap_ratio":
				dmg_arr[Enum.DmgType.AD] += (cur_unit_stat[Enum.Stat.AP] * effects[effect_id]) as int
			"ap_base_dmg":
				dmg_arr[Enum.DmgType.AP] += effects[effect_id] as int
			"ap_dmg_ad_ratio":
				dmg_arr[Enum.DmgType.AP] += (cur_unit_stat[Enum.Stat.AD] * effects[effect_id]) as int
			"ap_dmg_ap_ratio":
				dmg_arr[Enum.DmgType.AP] += (cur_unit_stat[Enum.Stat.AP] * effects[effect_id]) as int
			"pure_base_dmg":
				dmg_arr[Enum.DmgType.PR] += effects[effect_id] as int
			"pure_dmg_ad_ratio":
				dmg_arr[Enum.DmgType.PR] += (cur_unit_stat[Enum.Stat.AD] * effects[effect_id]) as int
			"pure_dmg_ap_ratio":
				dmg_arr[Enum.DmgType.PR] += (cur_unit_stat[Enum.Stat.AP] * effects[effect_id]) as int
			"acc_mod":
				cur_unit_stat[Enum.Stat.ACCURACY] += effects[effect_id] as int
			"crit_mod":
				cur_unit_stat[Enum.Stat.CRIT] += effects[effect_id] as int
			"self_buff":
				var dura : int = effects[effect_id]["duration"] as int				
				for buff_id in effects[effect_id].keys():
					if buff_id == "duration":
						continue
					self_buff_arr.append(BuffInfo.new(GlobalData.str_to_stat[buff_id], effects[effect_id][buff_id] as int, dura, true))
			"self_buff_per":
				var dura : int = effects[effect_id]["duration"] as int				
				for buff_id in effects[effect_id].keys():
					if buff_id == "duration":
						continue
					self_buff_arr.append(BuffInfo.new(GlobalData.str_to_stat[buff_id], effects[effect_id][buff_id] as int, dura, false))
			"target_buff":
				var dura : int = effects[effect_id]["duration"] as int				
				for buff_id in effects[effect_id].keys():
					if buff_id == "duration":
						continue
					target_buff_arr.append(BuffInfo.new(GlobalData.str_to_stat[buff_id], effects[effect_id][buff_id] as int, dura, true))
			"target_buff_per":
				var dura : int = effects[effect_id]["duration"] as int				
				for buff_id in effects[effect_id].keys():
					if buff_id == "duration":
						continue
					target_buff_arr.append(BuffInfo.new(GlobalData.str_to_stat[buff_id], effects[effect_id][buff_id] as int, dura, false))
			"self_marking":
				self_se_arr[Enum.SE.MARKED] += effects[effect_id] as int
			"self_concentration":
				self_se_arr[Enum.SE.CONCENTRATION] += effects[effect_id] as int
			"self_guard":
				target_se_arr[Enum.SE.GUARD] += 1
				self_se_arr[Enum.SE.BE_GUARDED] += effects[effect_id] as int
			"self_riposte":
				self_se_arr[Enum.SE.RIPOSTE] += effects[effect_id] as int
			"self_assist":
				self_se_arr[Enum.SE.ASSIST] += effects[effect_id] as int
			"self_stealth":
				self_se_arr[Enum.SE.STEALTH] += effects[effect_id] as int
			"target_marking":
				target_se_arr[Enum.SE.MARKED] += effects[effect_id] as int	
			"target_guard":
				self_se_arr[Enum.SE.GUARD] += 1
				target_se_arr[Enum.SE.BE_GUARDED] += effects[effect_id] as int
			"target_concentration":
				target_se_arr[Enum.SE.CONCENTRATION] += effects[effect_id] as int
			"unable_to_dodge":
				unable_to_dodge = true
			"self_move_forward":
				move_arr.append(MoveData.new(cast_unit.combat_pos, cast_unit.combat_pos % 2, cast_unit.is_enemy))
			"self_move_backward":
				var target_pos : int = cast_unit.combat_pos if cast_unit.combat_pos > 2 else cast_unit.combat_pos + 2
				move_arr.append(MoveData.new(cast_unit.combat_pos, target_pos, cast_unit.is_enemy))
			"target_move_forward":
				target_move_forward_skill = true
			"target_move_backward":
				target_move_backward_skill = true
			_:
				continue
	
	var is_root_method : bool = (not riposte and not assist)
	
	# play cast unit anim.
	cast_unit.play_anim("unit_animation/" + skill["id"])
	cast_unit.play_scale_motion(true)
	if cast_unit.is_enemy:
		cast_unit.play_pos_motion(enemy_motion_pos[cast_unit.combat_pos].position)
	else:
		cast_unit.play_pos_motion(player_motion_pos[cast_unit.combat_pos].position)

	# guard.
	if is_root_method and not cur_skill_is_friendly:
		for i in range(target_units.size() - 1, -1, -1):
			if target_units[i].remain_SE[Enum.SE.BE_GUARDED] > 0 and target_units[i].guard_unit not in target_units:
				target_units.append(target_units[i].guard_unit)
				target_units[i].guard_consume()
				target_units.remove_at(i)
	
	# targets hit.
	for target_unit in target_units:
		# play target unit anim.
		if cast_unit != target_unit:
			target_unit.play_scale_motion(true)
			if target_unit.is_enemy:
				target_unit.play_pos_motion(enemy_motion_pos[target_unit.combat_pos].position)
			else:
				target_unit.play_pos_motion(player_motion_pos[target_unit.combat_pos].position)
		
		if not (unable_to_dodge or cur_skill_is_friendly)\
			and (cur_unit_stat[Enum.Stat.ACCURACY] - target_unit.get_stat(Enum.Stat.DODGE)) <= randi_range(0,99):
			target_unit.dodged()
		else:
			var temp_dmg_arr : Array[int] = [0,0,0,0]
			
			if dmg_arr[Enum.DmgType.AD] != 0:
				temp_dmg_arr[Enum.DmgType.AD] = calculate_dmg_with_def(dmg_arr[Enum.DmgType.AD],
					target_unit.get_stat(Enum.Stat.ARM),
					cur_unit_stat[Enum.Stat.ARM_PEN],
					cur_unit_stat[Enum.Stat.ARM_PEN_PER])
			
			if dmg_arr[Enum.DmgType.AP] != 0:
				temp_dmg_arr[Enum.DmgType.AP] = calculate_dmg_with_def(dmg_arr[Enum.DmgType.AP], 
					target_unit.get_stat(Enum.Stat.MAG_RES),
					cur_unit_stat[Enum.Stat.MAG_PEN],
					cur_unit_stat[Enum.Stat.MAG_PEN_PER])
			
			var crit_occured : bool = cur_unit_stat[Enum.Stat.CRIT] > randi_range(0,99)
			if crit_occured:
				for i in dmg_arr.size():
					temp_dmg_arr[i] = (0.01 * temp_dmg_arr[i] * cur_unit_stat[Enum.Stat.CRIT_DMG]) as int
			
			target_unit.hit(temp_dmg_arr, crit_occured, cur_skill_is_friendly)
			target_unit.receive_status_effect(target_se_arr)
			
			if target_se_arr[Enum.SE.BE_GUARDED] > 0:
				target_unit.unit_be_guarded(target_se_arr[Enum.SE.BE_GUARDED], cast_unit)
			
			if self_se_arr[Enum.SE.BE_GUARDED] > 0:
				cast_unit.unit_be_guarded(self_se_arr[Enum.SE.BE_GUARDED], target_unit)
			
			if not target_buff_arr.is_empty():
				target_unit.receive_buff_or_debuff(target_buff_arr)
			
			if target_move_forward_skill:
				if target_unit.get_stat(Enum.Stat.MOVE_RES) <= randi_range(0,99):
					move_arr.append(MoveData.new(target_unit.combat_pos, target_unit.combat_pos % 2, target_unit.is_enemy))
			elif target_move_backward_skill:
				if target_unit.get_stat(Enum.Stat.MOVE_RES) <= randi_range(0,99):
					var target_pos : int = target_unit.combat_pos if target_unit.combat_pos > 2 else target_unit.combat_pos + 2
					move_arr.append(MoveData.new(target_unit.combat_pos, target_pos, target_unit.is_enemy))
	
	cast_unit.receive_status_effect(self_se_arr)
	if not self_buff_arr.is_empty():
		cast_unit.receive_buff_or_debuff(self_buff_arr)
	
	await get_tree().create_timer(1).timeout
	
	var riposte_unit_exist : bool = false
	var riposte_assist_unit_exist : bool = false
	var assist_unit_exist : bool = false
	
	#assist
	if not assist and not cur_skill_is_friendly:
		var assist_targets : Array[StatusController]
		for target in target_units:
			if not target.is_die:
				assist_targets.append(target)
		if not assist_targets.is_empty():
			if cast_unit.is_enemy:
				for enemy in enemies:
					if cast_unit != enemy and not enemy.is_die and enemy.remain_SE[Enum.SE.ASSIST] > 0:
						assist_unit_exist = true
						enemy.assist()
						cast_skill_to(enemy, assist_targets, GlobalData.unit_assist[enemy.unit_name], false, true)
			else:
				for player in players:
					if cast_unit != player and not player.is_die and player.remain_SE[Enum.SE.ASSIST] > 0:
						assist_unit_exist = true
						player.assist()
						cast_skill_to(player, assist_targets, GlobalData.unit_assist[player.unit_name], false, true)
					
	if assist_unit_exist:
		await get_tree().create_timer(1).timeout
	
	#riposte
	if is_root_method:
		if not cur_skill_is_friendly:
			for target_unit in target_units:
				if not target_unit.is_die and target_unit.remain_SE[Enum.SE.RIPOSTE] > 0:
					riposte_unit_exist = true
					if cast_unit.is_enemy:
						for player in players:
							if cast_unit != player and not player.is_die and player.remain_SE[Enum.SE.ASSIST] > 0:
								riposte_assist_unit_exist = true
					else:
						for enemy in enemies:
							if cast_unit != enemy and not enemy.is_die and enemy.remain_SE[Enum.SE.ASSIST] > 0:
								riposte_assist_unit_exist = true
					target_unit.riposte()
					cast_skill_to(target_unit, [cast_unit], GlobalData.unit_riposte[target_unit.unit_name], true, false)
		if riposte_unit_exist:
			await get_tree().create_timer(1).timeout
		if riposte_assist_unit_exist:
			await get_tree().create_timer(1).timeout
		await reset_all_unit_motion()
		
		# after animation end.
		for move_data in move_arr:
			if move_data == move_arr.back():
				change_combat_pos(move_data)
		
		if not move_arr.is_empty():
			await get_tree().create_timer(0.5).timeout

func calculate_dmg_with_def(dmg : int, def : int, def_pen : int, def_pen_per : float) -> int:
	def = ((def - def_pen) * (1 - def_pen_per)) as int
	
	if def < 0:
		def = 0
	
	return (1 + (1 / (1 + 0.02 * (def as float))) * dmg) as int

func change_combat_pos(move_data : MoveData):
	if move_data.cur_pos == move_data.end_pos:
		await get_tree().create_timer(0.5).timeout
	
	var cur_unit : StatusController = find_unit_in_place(move_data.cur_pos, move_data.is_enemy)
	if cur_unit == null:
		return
	
	var target_unit : StatusController = find_unit_in_place(move_data.end_pos, move_data.is_enemy)

	if move_data.is_enemy:
		if target_unit != null:
			target_unit.combat_pos = move_data.cur_pos
			target_unit.play_move_motion(enemy_positions[move_data.cur_pos].global_position)
		else:
			enemy_exist_in[move_data.cur_pos] = false
			enemy_exist_in[move_data.end_pos] = true
		
		cur_unit.combat_pos = move_data.end_pos
		cur_unit.play_move_motion(enemy_positions[move_data.end_pos].global_position)
	else:
		if target_unit != null:
			target_unit.combat_pos = move_data.cur_pos
			target_unit.play_move_motion(player_positions[move_data.cur_pos].global_position)
		else:
			player_exist_in[move_data.cur_pos] = false
			player_exist_in[move_data.end_pos] = true
		
		cur_unit.combat_pos = move_data.end_pos
		cur_unit.play_move_motion(player_positions[move_data.end_pos].global_position)
		
	await get_tree().create_timer(0.5).timeout

func turn_end():
	if is_combat_finished:
		hide_combat_ui()
		hide_skill_buttons()
		combat_finished()
		return
		
	player_ui.hide()
	enemy_ui.hide()
	
	for unit in combat_units:
		unit.manage_se_icons()
	
	await get_tree().create_timer(1).timeout
	
	if turn_process_array.is_empty():
		await turn_list.proceed_turn()
		for unit in combat_units:
			unit.end_of_period()
		period_process()
	else:
		turn_start(false)

func find_unit_in_place(exist_idx : int, is_enemy : bool) -> StatusController:
	if is_enemy:
		for enemy in enemies:
			if enemy.combat_pos == exist_idx:
				return enemy
	else:
		for player in players:
			if player.combat_pos == exist_idx:
				return player
	return null

func get_target_of_player_skill(chosen_unit : int) -> Array[StatusController]:
	var ret : Array[StatusController]
	
	if cur_skill_is_wide:
		for ch in cur_skill_target:
			ret.append(find_unit_in_place(ch as int, not cur_skill_is_friendly))
	else:
		ret.append(find_unit_in_place(chosen_unit, not cur_skill_is_friendly))
	
	return ret

func get_target_of_enemy_skill() -> Array[StatusController]:
	var ret : Array[StatusController]
	
	if cur_skill_is_wide:
		for ch in cur_skill_target:
			ret.append(find_unit_in_place(ch as int, cur_skill_is_friendly))

	else:
		var ch = cur_skill_target[randi_range(0, cur_skill_target.length()-1)]
		ret.append(find_unit_in_place(ch as int, cur_skill_is_friendly))
	
	return ret

func on_mouse_entered_unit(unit_idx : int, _is_enemy : bool):
	if current_turn_unit.is_enemy:
		return
	
	var find_unit : StatusController = find_unit_in_place(unit_idx, _is_enemy)
	turn_list.unit_focus(find_unit)
	
	if _is_enemy:
		manage_enemy_ui(find_unit)
		if enemy_highlights[unit_idx].visible:
			if cur_skill_is_wide:
				for ch in cur_skill_target:
					enemy_targeted[ch as int].show()
			else:
				enemy_targeted[unit_idx].show()
	else:
		manage_player_ui(find_unit)
		if player_highlights[unit_idx].visible:
			if cur_skill_is_wide:
				for ch in cur_skill_target:
					player_targeted[ch as int].show()
			else:
				player_targeted[unit_idx].show()
	
func on_mouse_exited_unit(unit_idx : int, _is_enemy : bool):
	if current_turn_unit.is_enemy:
		return
	
	turn_list.unit_unfocus(find_unit_in_place(unit_idx, _is_enemy))
	
	if _is_enemy:
		enemy_ui.hide()
		if enemy_highlights[unit_idx].visible:
			if cur_skill_is_wide:
				for ch in cur_skill_target:
					enemy_targeted[ch as int].hide()
			else:
				enemy_targeted[unit_idx].hide()
	else:
		manage_player_ui(current_turn_unit)
		if player_highlights[unit_idx].visible:
			if cur_skill_is_wide:
				for ch in cur_skill_target:
					player_targeted[ch as int].hide()
			else:
				player_targeted[unit_idx].hide()
	
func on_mouse_clicked_unit(vp, event : InputEvent, si, unit_idx : int, _is_enemy : bool):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if _is_enemy:
				if enemy_exist_in[unit_idx] and enemy_targeted[unit_idx].visible:
					reset_all_marks()
					hide_skill_buttons()
					hide_combat_ui()
					await cast_skill_to(current_turn_unit, get_target_of_player_skill(unit_idx), selected_skill, false, false)
					reset_all_unit_motion()
					show_combat_ui()
					reset_all_marks()
					turn_end()
			else:
				if selected_skill == GlobalData.move_skill:
					reset_all_marks()
					hide_skill_buttons()
					await change_combat_pos(MoveData.new(current_turn_unit.combat_pos, unit_idx, _is_enemy))
					reset_all_marks()
					turn_end()
					return
				if player_exist_in[unit_idx] and player_targeted[unit_idx].visible:
					reset_all_marks()
					hide_skill_buttons()
					hide_combat_ui()
					await cast_skill_to(current_turn_unit, get_target_of_player_skill(unit_idx), selected_skill, false, false)
					reset_all_unit_motion()
					show_combat_ui()
					reset_all_marks()
					turn_end()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# right click
			pass

func enemy_ai_act():
	var usable_skill : Array[int]
	
	var idx : int = 0
	for skill in GlobalData.unit_skills[current_turn_unit.unit_name]:
		var launch : String = skill["launch"]
		if str(current_turn_unit.combat_pos) not in launch:
			idx += 1
			continue
		
		var cost : Dictionary = skill["cost"]
		var unusable : bool = false
		for co in cost.keys():
			match co:
				"health":
					if current_turn_unit.remain_health <= cost[co] as int:
						unusable = true
				"health_per":
					if (current_turn_unit.remain_health as float / current_turn_unit.get_stat(Enum.Stat.HEALTH)) <= 0.01 * cost[co] as int:
						unusable = true
				"energy":
					if current_turn_unit.remain_energy < cost[co] as int:
						unusable = true
				"concentration":
					if current_turn_unit.remain_SE[Enum.SE.CONCENTRATION] < cost[co] as int:
						unusable = true
		
		if unusable:
			idx += 1
			continue
		
		var target : String = skill["target"]
		if not get_targetable_pos_string(target).is_empty():
			usable_skill.append(idx)
		idx += 1
	
	if usable_skill.is_empty():
		current_turn_unit.passed()
		reset_all_marks()
		turn_end()
		return
	
	var chosen_skill : int = usable_skill.pick_random()
	selected_skill = GlobalData.unit_skills[current_turn_unit.unit_name][chosen_skill]
	cur_skill_target = get_targetable_pos_string(selected_skill["target"])
	cur_skill_is_friendly = '@' in selected_skill["target"]
	cur_skill_is_wide = '&' in selected_skill["target"]
	
	var target_arr : Array[StatusController] = get_target_of_enemy_skill()
	
	if cur_skill_is_friendly:
		for _target in target_arr:
			enemy_targeted[_target.combat_pos].show()
	else:
		for _target in target_arr:
			player_targeted[_target.combat_pos].show()
	
	await get_tree().create_timer(1).timeout
	
	reset_all_marks()
	hide_combat_ui()
	await cast_skill_to(current_turn_unit, target_arr, selected_skill, false, false)
	reset_all_unit_motion()
	show_combat_ui()
	reset_all_marks()
	turn_end()

func unit_added(unit : StatusController):
	combat_units.append(unit)
	
	if unit.is_enemy:
		enemies.append(unit)
	else:
		players.append(unit)
	
func unit_removed(unit : StatusController):
	for turn_data in turn_process_array:
		if turn_data.unit == unit:
			turn_process_array.erase(turn_data)
			break
	
	combat_units.erase(unit)
	
	if unit.is_enemy:
		enemies.erase(unit)
		enemy_exist_in[unit.combat_pos] = false
	else:
		players.erase(unit)
		player_exist_in[unit.combat_pos] = false
	
	if enemies.is_empty() or players.is_empty():
		is_combat_finished = true

func on_skill_toggled(toggled_on : bool, skill_idx : int):
	reset_all_marks()
	player_turnmarks[current_turn_unit.combat_pos].show()
	if toggled_on:
		player_skill_selected(skill_idx)
	
func on_move_button_toggled(toggled_on : bool):
	reset_all_marks()
	if toggled_on:
		move_selected()

func hide_skill_buttons():
	for skill_button in skill_buttons:
		skill_button.button_pressed = false
	move_button.button_pressed = false
	
	skill_ui.hide()

func reset_all_marks():
	for i in player_targeted.size():
		player_targeted[i].hide()
		enemy_targeted[i].hide()
		player_highlights[i].hide()
		enemy_highlights[i].hide()
		player_turnmarks[i].hide()
		enemy_turnmarks[i].hide()

func manage_player_ui(player_unit : StatusController):
	if player_unit == null:
		return
	
	player_ui.show()
	
	player_portrait.texture = GlobalData.portraits[player_unit.unit_name]
	player_name.text = player_unit.unit_name
	
	for i in Enum.Stat.size():
		if i < 3:
			continue
		player_stat_texts[i-3].text = str(player_unit.get_stat(i))

func manage_enemy_ui(enemy_unit : StatusController):
	if enemy_unit == null:
		return
	
	enemy_ui.show()
	
	enemy_portrait.texture = GlobalData.portraits[enemy_unit.unit_name]
	enemy_name.text = enemy_unit.unit_name
	
	for i in Enum.Stat.size():
		if i < 3:
			continue
		enemy_stat_texts[i-3].text = str(enemy_unit.get_stat(i))
		
func hide_combat_ui():
	for unit in combat_units:
		unit.unit_ui.hide()
	combat_ui.hide()
	
func show_combat_ui():
	for unit in combat_units:
		unit.unit_ui.show()
	combat_ui.show()

func combat_finished():
	if players.is_empty():
		game_over()
	else:
		item_drop()
	
	combat_units.clear()
	turn_process_array.clear()
	players.clear()
	enemies.clear()
	
	combat_ui.hide()
	
	for i in player_exist_in.size():
		player_exist_in[i] = false
		enemy_exist_in[i] = false

func item_drop():
	var item_window = item_pop_up.instantiate()
	get_parent().add_child(item_window)
	item_window.item_drop_end.connect(back_to_map)

func game_over():
	pass
	
func back_to_map():
	get_parent().get_parent().active_map_scene()
