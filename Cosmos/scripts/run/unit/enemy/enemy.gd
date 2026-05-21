class_name Enemy extends Unit

const ATTACK_INTENT := preload("res://resources/sprites/icons/others/enemy_hostile.tres")
const AOE_ATTACK_INTENT := preload("res://resources/sprites/icons/others/enemy_hostile.tres")
const SUPPORT_INTENT := preload("res://resources/sprites/icons/others/enemy_friendly.tres")

@onready var intent_controller: Control = %IntentController
@onready var intent_icon: TextureRect = %IntentIcon
@onready var targeting_line: Line2D = %TargetingLine
@onready var special_ability_icon: TextureRect = %SpecialAbilityIcon

var cur_single_target : Unit : set = set_single_target
var preparing_skill : EnemySkill : set = set_preparing_skill
var last_casted_skill : EnemySkill = null

func _ready():
	super._ready()
	
	ui.hide()
	intent_icon.hide()
	special_ability_icon.hide()
	intent_controller.mouse_entered.connect(show_preparing_skill_info)
	intent_controller.mouse_exited.connect(hide_preparing_skill_info)
	special_ability_icon.mouse_entered.connect(show_special_ability)
	special_ability_icon.mouse_exited.connect(hide_special_ability)

func combat_start():
	ui.show()

func turn_start():
	super.turn_start()
	
	if cur_status_arr[Enum.Status.DEFENSELESS] > 0:
		change_status(Enum.Status.DEFENSELESS, -cur_status_arr[Enum.Status.DEFENSELESS])

func death():
	super.death()
	await get_tree().create_timer(1).timeout
	queue_free()

func set_data(unit_data : UnitData):
	super.set_data(unit_data)
	
	# play idle anim.
	create_and_play_idle_anim()
	
	targeting_line.points[0] = targetable_icon.position
	targeting_line.points[1] = targeting_line.points[0]
	
	if not data.passives.is_empty():
		special_ability_icon.show()

func create_and_play_idle_anim():
	var anim_lib := animation_player.get_animation_library("")
	var new_anim := Animation.new()
	new_anim.length = 4.0
	new_anim.loop_mode = Animation.LOOP_PINGPONG

	var track_index = new_anim.add_track(Animation.TYPE_VALUE)
	new_anim.track_set_path(track_index, "Sprite:scale")
	new_anim.track_insert_key(track_index, 0.0, sprite.scale)
	new_anim.track_insert_key(track_index, 4.0, 1.1 * sprite.scale)

	anim_lib.add_animation("idle", new_anim)
	animation_player.play("idle", -1, randf_range(0.9,1.1))
	animation_player.seek(randf_range(0,4))

func set_single_target(target : Unit):
	if cur_single_target and cur_single_target is Player:
		cur_single_target.targeted_count -= 1
	
	cur_single_target = target
	
	if target and target is Player:
		target.targeted_count += 1
		targeting_line.show()
		var tween := create_tween()
		tween.tween_method(
		func(value : Vector2):
			targeting_line.points[1] = value,
			targeting_line.points[1],
			target.targetable_icon.global_position - targetable_icon.global_position,
			0.5
		)
		if target is Player:
			targeting_line.modulate = Color.RED
		else:
			targeting_line.modulate = Color.GREEN
	else:
		targeting_line.hide()
		targeting_line.points[1] = targeting_line.points[0]

func set_preparing_skill(skill : EnemySkill):
	preparing_skill = skill
	
	if skill:
		# set intent icon.
		if skill.is_friendly():
			intent_icon.texture = SUPPORT_INTENT
		else:
			if skill.target == Skill.Target.ALL_ENEMY:
				intent_icon.texture = AOE_ATTACK_INTENT
			else:
				intent_icon.texture = ATTACK_INTENT
		
		intent_icon.show()
	else:
		cur_single_target = null
		intent_icon.hide()

func get_pre_turn_skills() -> Array[EnemySkill]:
	var ret : Array[EnemySkill] = []
	
	for skill : EnemySkill in data.skills:
		if skill.is_pre_turn_skill:
			ret.append(skill)
	
	return ret

func exhaust():
	super.exhaust()
	preparing_skill = null

func show_preparing_skill_info():
	if preparing_skill:
		SubInfoLayer.show_skill_tooltip(preparing_skill, intent_icon.global_position)

func hide_preparing_skill_info():
	SubInfoLayer.hide_skill_tooltip()

func show_special_ability():
	SubInfoLayer.show_ability_tooltip(data.passives, special_ability_icon.global_position)

func hide_special_ability():
	SubInfoLayer.hide_ability_tooltip()
