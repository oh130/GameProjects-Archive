class_name Combat extends Node

const ENEMY_SCENE := preload("res://scenes/run/unit/enemy.tscn")
const COMBAT_SKILL_UI_SCENE := preload("res://scenes/run/combat/combat_skill_ui.tscn")

const PASS_GAIN_ENERGY := 10
const ENEMY_CAST_WAIT_TIME := 1

const ENEMY_MIDDLE_POS := Vector2(640,380)
const ENEMY_POS_DIFF := Vector2(260,0)

@onready var camera: Camera2D = %Camera
@onready var player_info: PlayerInfo = %PlayerInfo

@onready var combat_ui: Control = %CombatUI
@onready var enemy_container: Control = %EnemyContainer
@onready var enemy_info: EnemyInfo = %EnemyInfo
@onready var turn_label: Label = %TurnLabel

@onready var act_entry: VBoxContainer = %ActEntry
@onready var stance_buttons: HBoxContainer = %StanceButtons
@onready var turn_pass_button: Button = %TurnPassButton
@onready var skill_entry: GridContainer = %SkillEntry

@onready var skill_name_ui: Label = %SkillNameUI
@onready var turn_banner: ColorRect = %TurnBanner

var players : Array[Unit]
var enemies : Array[Unit]
var current_turn_unit : Unit : set = set_current_turn_unit
var selected_skill : PlayerSkill : set = set_selected_skill
var targetable_units : Array[Unit]
var turn : int :
	set(value):
		turn = value
		turn_label.text = tr("TURN") + " %d" % turn

signal combat_end_signal()
signal game_over_signal()

func _ready():
	AnimationManager.camera = camera
	
	combat_ui.hide()
	skill_name_ui.hide()
	
	turn_pass_button.pressed.connect(passing_turn)
	
	var i := 0
	for child : Button in stance_buttons.get_children():
		child.icon = SubInfoLayer.stance_icons[i]
		child.toggled.connect(set_stance.bind(i))
		i += 1
	
	act_entry.hide()
	turn_banner.hide()

func _input(event: InputEvent) -> void:
	if GameManager.deny_input or not SituationManager.on_combat:
		return
	
	if event.is_action_pressed("right_mouse"):
		selected_skill = null

func init_enemy_pool():
	var pool : Array[EnemyGroup]
	for enemy_group in Pool.enemy_group_pool:
		if enemy_group.appear_chapter == DataManager.save_data.chapter.resource_name\
		or enemy_group.appear_chapter == "":
			pool.append(enemy_group)
	
	Random.array_shuffle(pool)
	DataManager.save_data.current_enemy_group_pool = pool

func init_elite_pool():
	var pool : Array[EnemyGroup]
	for enemy_group in Pool.elite_group_pool:
		if enemy_group.appear_chapter == DataManager.save_data.chapter.resource_name:
			pool.append(enemy_group)
	
	Random.array_shuffle(pool)
	DataManager.save_data.current_elite_group_pool = pool

func create_enemy(enemy_data : EnemyData, pos : Vector2):
	var inst := ENEMY_SCENE.instantiate()
	enemy_container.add_child(inst)
	inst.position = pos
	enemies.append(inst)
	
	inst.focus_unit.connect(enemy_mouse_entered)
	inst.unfocus_unit.connect(enemy_mouse_exited)
	inst.select_unit.connect(enemy_clicked)
	inst.died.connect(handle_unit_died)
	inst.stat_changed.connect(enemy_info.update_stats)
	
	enemy_data.initialize()
	inst.data = enemy_data

func append_player(player : Player):
	player.focus_unit.connect(player_mouse_entered)
	player.unfocus_unit.connect(player_mouse_exited)
	player.select_unit.connect(player_clicked)
	player.stat_changed.connect(player_info.update_stats)
	player.died.connect(handle_unit_died)
	
	players.append(player)

### combat start, proceed, end ###

func start_combat(combat_type : Enum.Route):
	# spawn enemy.
	var enemy_group : EnemyGroup
	
	match combat_type:
		Enum.Route.ELITE:
			if DataManager.save_data.current_elite_group_pool.is_empty():
				init_elite_pool()
			enemy_group = DataManager.save_data.current_elite_group_pool.pop_back()
		Enum.Route.BOSS:
			var boss_pool : Array[EnemyGroup] = []
			for boss in Pool.boss_group_pool:
				if boss.appear_chapter == DataManager.save_data.chapter.resource_name:
					boss_pool.append(boss)
			
			enemy_group = Random.pick_random(boss_pool)
		_:
			if DataManager.save_data.current_enemy_group_pool.is_empty():
				init_enemy_pool()
			enemy_group = DataManager.save_data.current_enemy_group_pool.pop_back()
	
	var pos_arr : Array[Vector2]
	match enemy_group.enemy_list.size():
		1:
			pos_arr.append(get_rand_point(ENEMY_MIDDLE_POS))
		2:
			pos_arr.append(get_rand_point(ENEMY_MIDDLE_POS - 0.5 * ENEMY_POS_DIFF))
			pos_arr.append(get_rand_point(ENEMY_MIDDLE_POS + 0.5 * ENEMY_POS_DIFF))
		3:
			pos_arr.append(get_rand_point(ENEMY_MIDDLE_POS - ENEMY_POS_DIFF))
			pos_arr.append(get_rand_point(ENEMY_MIDDLE_POS))
			pos_arr.append(get_rand_point(ENEMY_MIDDLE_POS + ENEMY_POS_DIFF))
	
	for i in enemy_group.enemy_list.size():
		var enemy_data : EnemyData = enemy_group.enemy_list[i].duplicate()
		enemy_data.resource_name = Pool.get_id(enemy_group.enemy_list[i])
		create_enemy(enemy_data, pos_arr[i])
	
	# encounter.
	Audio.stop_bgm()
	SituationManager.on_combat = true
	Audio.play_sfx(Audio.combat_encounter)
	await get_tree().create_timer(1).timeout
	
	# after encounter.
	for p in players:
		SituationManager.occur(Enum.Situation.COMBAT_ENTER, p)
	Audio.play_bgm(DataManager.save_data.chapter.combat_bgm)
	
	set_enemy_info(enemies.front().data)
	GameManager.show_tween(combat_ui)
	turn = 0
	
	for p in players:
		p.combat_start()
	
	for e in enemies:
		e.combat_start()
	
	# start combat.
	turn_proceed()

func get_rand_point(pos : Vector2, ran : float = 20.0) -> Vector2:
	var offset_x := randf_range(-ran, ran)
	var offset_y := randf_range(-ran, ran)
	return pos + Vector2(offset_x, offset_y)

func handle_unit_died():
	var erase_arr : Array[Unit]
	for player in players:
		if player.is_died:
			erase_arr.append(player)
			if targetable_units.has(player):
				targetable_units.erase(player)
	
	for enemy : Enemy in enemies:
		if enemy.is_died:
			enemy.preparing_skill = null
			erase_arr.append(enemy)
			if targetable_units.has(enemy):
				targetable_units.erase(enemy)
	
	for enemy : Enemy in enemies:
		if enemy.cur_single_target and erase_arr.has(enemy.cur_single_target):
			enemy.preparing_skill = null
	
	for unit in erase_arr:
		if unit is Player:
			players.erase(unit)
			for p in players:
				if not p.is_died:
					SituationManager.occur(Enum.Situation.ALLY_DEATH, p)
		else:
			enemies.erase(unit)
	
	if players.is_empty():
		SituationManager.on_combat = false
		game_over_signal.emit()
	elif enemies.is_empty():
		end_combat()

func end_combat():
	SituationManager.on_combat = false
	SituationManager.on_enemy_turn = false
	await get_tree().create_timer(2).timeout
	
	for player in players:
		player.combat_ended()
	
	DataManager.save_data.difficulty += turn
	enemies.clear()
	combat_ui.hide()
	combat_end_signal.emit()
	
	if not DataManager.run.focused_player:
		DataManager.run.focused_player = DataManager.run.players.front()
	else:
		DataManager.run.set_focused_player(DataManager.run.focused_player)

# only execute in player turn.
func turn_check():
	for player : Player in players:
		if player.has_remain_turn:
			current_turn_unit = player
			DataManager.run.focused_player = player
			return
	
	# if all player acted, enemy act.
	await enemy_turn()
	
	if SituationManager.on_combat:
		for enemy : Enemy in enemies:
			if enemy.data.energy == 0:
				enemy.data.energy = enemy.get_unsigned_stat(Enum.Stat.MAX_ENERGY)
		
		turn_proceed()

func turn_proceed():
	turn += 1
	
	for enemy : Enemy in enemies:
		enemy.is_highlighted = true
		var pre_turn_skills := enemy.get_pre_turn_skills()
		if pre_turn_skills.is_empty():
			continue
		
		for skill : EnemySkill in pre_turn_skills:
			var targets : Array[Unit]
			match skill.target:
				Skill.Target.SELF:
					targets = [enemy]
				Skill.Target.ALLY:
					targets = [SubRandom.pick_random(enemies)]
				Skill.Target.ALLY_EXCEPT_SELF:
					var picked_target : Enemy = SubRandom.pick_random(enemies)
					while picked_target == enemy:
						picked_target = SubRandom.pick_random(enemies)
					targets = [picked_target]
				Skill.Target.ALL_ALLY:
					targets = enemies.duplicate()
				
				Skill.Target.ENEMY:
					targets = [SubRandom.pick_random(players)]
				Skill.Target.ALL_ENEMY:
					targets = players.duplicate()
			
			await cast_skill(enemy, targets, skill)
	
	# player first.
	player_turn()

func player_turn():
	Audio.play_sfx(Audio.player_turn)
	await handle_turn_banner()
	SituationManager.on_enemy_turn = false
	
	# why dup : check player died by rift.
	var dup_players := players.duplicate()
	for player : Player in dup_players:
		player.turn_start()
	
	# show enemy intent.
	for unit in enemies:
		enemy_select_skill(unit)
	
	turn_check()

func enemy_turn():
	for player : Player in players:
		player.turn_end()
	
	SituationManager.on_enemy_turn = true
	# enemy turn proceed.
	DataManager.run.focused_player = null
	Audio.play_sfx(Audio.enemy_turn)
	await handle_turn_banner(true)
	
	# why duplicate: player counter can kill enemy -> enemies(array) loop interrupted.
	var dup_enemies := enemies.duplicate()
	for enemy : Enemy in dup_enemies:
		enemy.turn_start()
		if enemy.is_died or not enemy.preparing_skill:
			continue
		
		current_turn_unit = enemy
		
		var targets : Array[Unit]
		match enemy.preparing_skill.target:
			Skill.Target.ALL_ALLY:
				targets = enemies.duplicate()
			Skill.Target.ALL_ENEMY:
				targets = players.duplicate()
			_:
				targets = [enemy.cur_single_target]
		
		await cast_skill(enemy, targets, enemy.preparing_skill)


func handle_turn_banner(enemy_turn_flag := false):
	turn_banner.get_child(0).text = "ENEMY_TURN" if enemy_turn_flag else "PLAYER_TURN"
	turn_banner.show()
	turn_banner.modulate.a = 0
	var tween := create_tween()
	tween.tween_property(turn_banner, "modulate:a", 1, 0.2)
	await tween.finished
	
	await get_tree().create_timer(0.4).timeout
	
	tween = create_tween()
	tween.tween_property(turn_banner, "modulate:a", 0, 0.2)
	await tween.finished
	turn_banner.hide()

func passing_turn():
	SituationManager.occur(Enum.Situation.TURN_PASS, current_turn_unit as Player)
	current_turn_unit.has_remain_turn = false
	current_turn_unit.data.energy += PASS_GAIN_ENERGY
	clear_current_selected()
	await Audio.play_sfx(Audio.turn_pass)
	turn_check()

### input behaviors ###

func set_player_info(player_data : PlayerData):
	player_info.data = player_data

func set_enemy_info(enemy_data : EnemyData):
	enemy_info.data = enemy_data

func player_mouse_entered(player : Player):
	set_player_info(player.data)

func player_mouse_exited():
	if not SituationManager.on_combat:
		if DataManager.run.focused_player:
			set_player_info(DataManager.run.focused_player.data)
	else:
		if current_turn_unit and current_turn_unit is Player:
			set_player_info(current_turn_unit.data)

func enemy_mouse_entered(enemy : Enemy):
	set_enemy_info(enemy.data)

func enemy_mouse_exited():
	if current_turn_unit and current_turn_unit is Enemy:
		set_enemy_info(current_turn_unit.data)

func player_clicked(player : Unit):
	if not SituationManager.on_combat:
		return
	
	if player.is_targetable:
		var targets : Array[Unit]
		if selected_skill.target == Skill.Target.ALL_ALLY:
			targets = players.duplicate()
		else:
			targets = [player]
		
		cast_skill(current_turn_unit, targets, selected_skill)
	
	elif player.has_remain_turn and player != current_turn_unit:
		current_turn_unit = player

func enemy_clicked(enemy : Unit):
	if selected_skill and enemy.is_targetable and not enemy.is_died:
		var targets : Array[Unit]
		if selected_skill.target == Skill.Target.ENEMY:
			targets = [enemy]
		else:
			targets = enemies.duplicate()
		
		cast_skill(current_turn_unit, targets, selected_skill)

func set_current_turn_unit(unit : Unit):
	current_turn_unit = unit
	selected_skill = null
	
	if unit == null:
		act_entry.hide()
	else:
		if unit is Player:
			SituationManager.occur(Enum.Situation.COMBAT_FOCUSED, unit as Player)
			DataManager.run.focused_player = unit
			act_entry.show()
			
			for child in skill_entry.get_children():
				skill_entry.remove_child(child)
			
			(stance_buttons.get_child(unit.stance) as Button).button_pressed = true
			
			for skill : PlayerSkill in (unit.data as PlayerData).selected_skills:
				var skill_ui : CombatSkillUI = COMBAT_SKILL_UI_SCENE.instantiate()
				skill_entry.add_child(skill_ui)
				skill_ui.data = skill
				skill_ui.disabled = get_skill_available_targets(unit, skill).is_empty()
				skill_ui.combat_skill_select_signal.connect(skill_ui_pressed)
		
		else:
			unit.is_highlighted = true
			for p in players:
				p.is_targetable = false
			for e in enemies:
				e.is_targetable = false
			targetable_units.clear()
			act_entry.hide()
			set_enemy_info(unit.data)

func clear_current_selected():
	current_turn_unit = null
	for unit in players:
		unit.is_targetable = false
	for unit in enemies:
		unit.is_targetable = false
	targetable_units.clear()

### about skills ###

func enemy_select_skill(enemy : Enemy):
	# enemy skills must be sorted as priority(first is much priority).
	# what if same priority skills(e.g. basic skills)? check 'has_priority' var. if false, then basic skill.
	var special_skills : Array[EnemySkill]
	var basic_skills : Array[EnemySkill]
	
	for skill : EnemySkill in enemy.data.skills:
		if skill.is_pre_turn_skill:
			continue
		
		if not get_skill_available_targets(enemy, skill).is_empty():
			if skill.has_priority:
				special_skills.append(skill)
			else:
				basic_skills.append(skill)
	
	var picked_skill : EnemySkill
	if not special_skills.is_empty():
		picked_skill = special_skills.front()
	elif not basic_skills.is_empty():
		picked_skill = SubRandom.pick_random(basic_skills)
		if basic_skills.size() > 1:
			while picked_skill == enemy.last_casted_skill:
				picked_skill = SubRandom.pick_random(basic_skills)
	
	if picked_skill:
		var available_targets := get_skill_available_targets(enemy, picked_skill)
		enemy.preparing_skill = picked_skill
		if not (picked_skill.target == Skill.Target.ALL_ALLY\
			or picked_skill.target == Skill.Target.ALL_ENEMY):
			enemy.cur_single_target = SubRandom.pick_random(available_targets)
	else:
		enemy.preparing_skill = null

func set_stance(toggled_on : bool, stance : Enum.Stance):
	if toggled_on:
		current_turn_unit.stance = stance

func set_selected_skill(skill : PlayerSkill):
	selected_skill = skill
	
	for unit in targetable_units:
		unit.is_targetable = false
	targetable_units.clear()
	
	if skill == null:
		for skill_ui : CombatSkillUI in skill_entry.get_children():
			skill_ui.button_pressed = false
	else:
		for unit in get_skill_available_targets(current_turn_unit, skill):
			append_targetable_unit(unit)

func skill_ui_pressed(skill : Skill):
	selected_skill = skill

func append_targetable_unit(unit : Unit):
	unit.is_targetable = true
	targetable_units.append(unit)

func get_skill_available_targets(caster : Unit, skill : Skill) -> Array[Unit]:
	# WHAT TO DO
	# 1. check skill cost.
	# 2. check skill conditions for it's targets.
	var ret : Array[Unit]
	var friendly_units : Array[Unit] = players if caster is Player else enemies
	var hostile_units : Array[Unit] = enemies if caster is Player else players
	
	match skill.target:
		Skill.Target.ALLY:
			for unit in friendly_units:
				if check_skill_condition(caster, skill, unit):
					ret.append(unit)
		Skill.Target.ALLY_EXCEPT_SELF:
			for unit in friendly_units:
				if unit != caster and check_skill_condition(caster, skill, unit):
					ret.append(unit)
		Skill.Target.ALL_ALLY:
			if check_skill_condition(caster, skill):
				ret.append_array(friendly_units)
		Skill.Target.ENEMY:
			for unit in hostile_units:
				if check_skill_condition(caster, skill, unit):
					ret.append(unit)
		Skill.Target.ALL_ENEMY:
			if check_skill_condition(caster, skill):
				ret.append_array(hostile_units)
		_:
			if check_skill_condition(caster, skill):
				ret.append(caster)
	
	var stealth_units : Array[Unit]
	for unit in ret:
		if unit.cur_status_arr[Enum.Status.STEALTH] > 0:
			stealth_units.append(unit)
	for unit in stealth_units:
		ret.erase(unit)
	
	return ret

func check_skill_condition(caster : Unit, skill : Skill, target : Unit = null) -> bool:
	for cond in skill.self_conditions:
		var val := skill.self_conditions[cond]
		
		match cond:
			pass
	
	for cond in skill.target_conditions:
		var val := skill.target_conditions[cond]
		
		match cond:
			pass
	
	# target variable only use in single target skill.
	for cost in skill.costs:
		var val := skill.costs[cost]
		
		match cost:
			Skill.Cost.HEALTH:
				if caster.data.health <= val:
					return false
			Skill.Cost.ENERGY:
				if caster.data.energy < val:
					return false
	
	return true

func consume_skill_costs(caster : Unit, targets : Array[Unit], skill : Skill):
	if caster is Player and not skill.special_effects.has(SkillEffects.SpecialEffect.NOT_CONSUME_TURN):
		caster.has_remain_turn = false
	for cost in skill.costs:
		var val := skill.costs[cost]
		
		match cost:
			Skill.Cost.HEALTH:
				caster.data.health -= val
			Skill.Cost.ENERGY:
				caster.data.energy -= val
			
			Skill.Cost.ALL_ENERGY:
				caster.data.energy -= caster.data.energy

func cast_skill(caster : Unit, targets : Array[Unit], skill : Skill):
	SituationManager.on_skill_anim = true
	### pre-animation ###
	GameManager.show_tween(skill_name_ui, 0.1)
	if caster is Enemy:
		skill_name_ui.text = Pool.get_id(skill)
		for target in targets:
			target.is_targetable = true
		
		await get_tree().create_timer(ENEMY_CAST_WAIT_TIME).timeout
		#await get_tree().physics_frame
		caster.is_highlighted = false
		caster.last_casted_skill = caster.preparing_skill
		caster.preparing_skill = null
	else:
		skill_name_ui.text = skill.resource_name
	
	# consume skill costs.
	var repeat_time := skill.repeat_time
	if skill.amount_effects.has(SkillEffects.AmountEffect.ADD_REPEAT_TIME_PER_ENERGY_AMOUNT):
		# add repeat time per energy amount = only used at MAX ENERGY CONSUME skill.
		@warning_ignore("integer_division")
		repeat_time += caster.data.energy /\
		skill.amount_effects[SkillEffects.AmountEffect.ADD_REPEAT_TIME_PER_ENERGY_AMOUNT].apply_ratios(caster.get_all_unsigned_stat())
	
	consume_skill_costs(caster, targets, skill)
	clear_current_selected()
	
	for i in repeat_time:
		if not caster or caster.is_died:
			return
		
		var skill_effects := SkillEffects.new()
		skill_effects.init_skill_general_effects(caster, skill, false, false)
	
		Audio.play_sfx(skill.sfx)
		for target in targets:
			skill_effects.cast_to_target(target)
		
		skill_effects.after_effect()
		
		# animation.
		await AnimationManager.skill_anim(caster, targets, skill.is_friendly())
		
		# sub act.
		if not skill.is_friendly() and caster:
			# counter.
			if caster is Enemy:
				for target : Player in targets:
					await act_counter(target, caster)
			
			# assist.
			else:
				await trigger_assist(caster, targets)
		
		var all_died := true
		for target in targets:
			if not target.is_died:
				all_died = false
		
		if all_died:
			break
	
	# break cost must be consumed after cast.
	if skill.costs.has(Skill.Cost.TARGET_ALL_BREAK):
		for target in targets:
			if not target or target.is_died:
				continue
			target.change_status(Enum.Status.BREAK, -target.cur_status_arr[Enum.Status.BREAK])
	
	if not caster or caster.is_died:
		return
	
	if caster is Player:
		SituationManager.occur(Enum.Situation.CAST, caster, skill)
		for p in players:
			if p != caster:
				SituationManager.occur(Enum.Situation.ALLY_ACTED, p)
	
	SituationManager.on_skill_anim = false
	
	GameManager.hide_tween(skill_name_ui, 0.1)
	await get_tree().create_timer(1).timeout
	
	if caster is Player and SituationManager.on_combat:
		turn_check()

func act_counter(caster : Unit, target : Unit):
	if not (caster and not caster.is_died and caster.stance == Enum.Stance.COUNTER\
	and check_skill_condition(caster, caster.data.counter)\
	and SubRandom.roll_chance(caster.get_unsigned_stat(Enum.Stat.COUNTER_CHANCE))):
		return
	
	consume_skill_costs(caster, [target], caster.data.counter)
	SituationManager.occur(Enum.Situation.COUNTER, caster)
	
	for i in caster.data.counter.repeat_time:
		var skill_effects := SkillEffects.new()
		skill_effects.init_skill_general_effects(caster, caster.data.counter, true, false)
		skill_effects.cast_to_target(target)
		skill_effects.after_effect()
		
		# animation.
		await AnimationManager.skill_anim(caster, [target], false)
		# counter can trigger assist.
		await trigger_assist(caster, [target])

func trigger_assist(main_caster : Unit, targets : Array[Unit]):
	for caster : Player in players:
		if caster != main_caster and caster and not caster.is_died\
		and caster.stance == Enum.Stance.ASSIST:
			
			for target : Enemy in targets:
				if target and not target.is_died and\
				check_skill_condition(caster, caster.data.assist)\
				and SubRandom.roll_chance(caster.get_unsigned_stat(Enum.Stat.ASSIST_CHANCE)):
					
					consume_skill_costs(caster, [target], caster.data.assist)
					SituationManager.occur(Enum.Situation.ASSIST, caster)
					
					for i in caster.data.assist.repeat_time:
						var skill_effects := SkillEffects.new()
						skill_effects.init_skill_general_effects(caster, caster.data.assist, false, true)
						skill_effects.cast_to_target(target)
						skill_effects.after_effect()
						
						# animation.
						await AnimationManager.skill_anim(caster, [target], false)
