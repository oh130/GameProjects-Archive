class_name Ground extends TileMapLayer

#region Variables

enum State 
{ 
	BASIC, 
	PAINTING, 
	CALLING, 
	PLAYER_ACTOR_SELECTED
}

const STARTING_INK := 10000
const MAP_WIDTH := 9
const HEALTH_BAR_POS_MOD := Vector2(0,10)

const BASE_SCENE := preload("res://scenes/stage/armament/structures/base.tscn")
const ARMAMENT_CALL_SCENE := preload("res://scenes/stage/ui/armament_call.tscn")
const HEALTH_BAR_SCENE := preload("res://scenes/stage/ui/health_bar.tscn")

@onready var stage: Stage = get_parent()
@onready var focus: Focus = %Focus

@onready var units: Node2D = %Units
@onready var structures: Node2D = %Structures
@onready var weapons: Node2D = %Weapons
@onready var health_bars: Control = %HealthBars

@onready var ink_text: Label = %InkText
@onready var current_tile_info: Label = %CurrentTileInfo
@onready var upgrade_button: Button = %UpgradeButton

@onready var call_table: HBoxContainer = %CallTable
@onready var paint_call: PaintCall = %PaintCall
@onready var selected_info: Control = %SelectedInfo
@onready var selected_portrait: TextureRect = %SelectedPortrait
@onready var selected_id: Label = %SelectedID

@onready var move_button: Button = %MoveButton
@onready var attack_button: Button = %AttackButton
@onready var eliminate_button: Button = %EliminateButton

@onready var state_text: Label = %StateText

# base.
@export var upgrade_cost : Array[int]
var base_tier : int

var current_state := State.BASIC
var mouse_coord : Vector2i
var prev_mouse_coord : Vector2i
var clickable : bool : set = set_clickable

# tiles.
var current_painted_tiles : Dictionary	# have painted tiles at key, tile hp at value.
var actor_existing_tiles : Dictionary	# have tile coords at key, actor at value.
var coord_to_health_bars : Dictionary	# have tile coords at key, health bar at value.
var eliminate_priority_queue : Array[Unit]

var total_painted_count := 0 : 
	set(value):
		total_painted_count = value
		current_tile_info.text = str(total_used_count) + " / " + str(value)
		unused_count = value - total_used_count
# note : only units use tiles.
var total_used_count := 0 :
	set(value):
		total_used_count = value
		current_tile_info.text = str(value) + " / " + str(total_painted_count)
		unused_count = total_painted_count - value
var unused_count := 0 :
	set(value):
		unused_count = value
		check_armament_calls.emit()
	
		if unused_count < 0:
			eliminate_unit_in_queue(-unused_count)

var tile_max_health := 3

var ink : int : set = set_ink
var ink_earning_per_tile := 1

# call prepare.
var prepared_armament : ArmamentCall

# selected.
var selected_actor : Actor : set = set_selected_actor
var current_commandable_coords : Array[Vector2i]
var is_move_command := false

# boolean.
var on_enemy_turn := false
var on_acting := false

signal ink_changed()
signal check_armament_calls()
signal tile_painted(coord : Vector2i)
signal tile_erased(coord : Vector2i)
#endregion

#region Basis Methods
func _ready():
	GameManager.ground = self
	selected_info.hide()
	
	# set up.
	paint_call.pressed.connect(paint_prepare)
	ink_changed.connect(paint_call.check_callable)
	
	EventBus.player_turn.connect(
		func():
			on_enemy_turn = false
			get_ink_resource()
	)
	EventBus.enemy_turn.connect(
		func():
			on_enemy_turn = true
	)
	
	for item_data in GameManager.picked_items:
		if not item_data is ArmamentData:
			item_data.apply_strategy()
		
		var armament_call := ARMAMENT_CALL_SCENE.instantiate()
		armament_call.data = item_data
		
		armament_call.pressed.connect(call_prepare.bind(armament_call))
		ink_changed.connect(armament_call.check_callable)
		check_armament_calls.connect(armament_call.check_callable)
		
		call_table.add_child(armament_call)
	
	ink_changed.connect(
		func():
			upgrade_button.disabled =\
				base_tier < upgrade_cost.size() and ink < upgrade_cost[base_tier]
	)
	
	# set health bars.
	var ran := range(-MAP_WIDTH, MAP_WIDTH + 1)
	for i in ran:
		for j in ran:
			var coord := Vector2i(i,j)
			var health_bar := HEALTH_BAR_SCENE.instantiate()
			health_bar.pos = (map_to_local(coord) + HEALTH_BAR_POS_MOD)
			health_bars.add_child(health_bar)
			health_bar.hide()
			
			coord_to_health_bars[coord] = health_bar

func _physics_process(_delta: float):
	if GameManager.stage_finished or on_enemy_turn or on_acting:
		clickable = false
		return
	
	mouse_coord = local_to_map(get_global_mouse_position())
	clickable = check_clickable()
	check_health_bar()

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.stage_finished or on_enemy_turn or on_acting:
		return
	
	if event.is_action_pressed("left_mouse"):
		if not clickable:
			change_state(State.BASIC)
			return
		
		match current_state:
			State.BASIC:
				selecting()
			State.PAINTING:
				painting()
			State.CALLING:
				calling()
			State.PLAYER_ACTOR_SELECTED:
				if is_move_command:
					commanding_move()
				else:
					commanding_attack()
		
	elif event.is_action_pressed("right_mouse"):
		change_state(State.BASIC)

func stage_started():
	ink = STARTING_INK
	
	var ran := [-1, 0, 1]
	for i in ran:
		for j in ran:
			var coord := Vector2i.ZERO + Vector2i(i,j)
			paint_tile(coord)
	
	var base : Structure = BASE_SCENE.instantiate()
	
	base.position = map_to_local(Vector2i.ZERO)
	base.died.connect(stage.stage_failed)
	actor_existing_tiles[Vector2i.ZERO] = base
	structures.add_child(base)
#endregion

#region Ink
func set_ink(value : int):
	ink = value
	ink_text.text = str(ink)
	
	ink_changed.emit()

func consume_ink(amount : int):
	ink -= amount
#endregion

#region State Handling
func change_state(state : State):
	current_state = state
	state_text.text = State.keys()[state]
	
	selected_actor = null
	clickable = false
	focus.total_clear()

func check_clickable() -> bool:
	if not coord_checker(mouse_coord):
		return false
	
	match current_state:
		State.BASIC:
			return actor_existing_tiles.has(mouse_coord)
		
		State.PAINTING:
			if current_painted_tiles.has(mouse_coord):
				return false
			
			for near_coord in get_surrounding_cells(mouse_coord):
				if current_painted_tiles.has(near_coord):
					return true
			
			return false
		
		State.CALLING:
			if true: # not tactical weapon
				return current_painted_tiles.has(mouse_coord)\
					and not actor_existing_tiles.has(mouse_coord)
		
		State.PLAYER_ACTOR_SELECTED:
			if is_move_command:
				return current_commandable_coords.has(mouse_coord)
			else:
				return current_commandable_coords.has(mouse_coord)\
				and actor_existing_tiles.has(mouse_coord)\
				and actor_existing_tiles[mouse_coord] is Enemy
	
	return true

func set_clickable(value : bool):
	clickable = value
	
	focus.clear()
	if value:
		focus.clickable_focus(mouse_coord)

func check_health_bar():
	if mouse_coord != prev_mouse_coord:
		if coord_checker(prev_mouse_coord):
			coord_to_health_bars[prev_mouse_coord].hide()
		if coord_checker(mouse_coord):
			if current_painted_tiles.has(mouse_coord):
				coord_to_health_bars[mouse_coord].show_health_bar(
					current_painted_tiles[mouse_coord],
					tile_max_health
				)
			elif actor_existing_tiles.has(mouse_coord)\
			and actor_existing_tiles[mouse_coord] is Enemy:
				coord_to_health_bars[mouse_coord].show_health_bar(
					actor_existing_tiles[mouse_coord].health,
					actor_existing_tiles[mouse_coord].data.max_health
				)
	
	prev_mouse_coord = mouse_coord
#endregion

#region About Actor, Select and Command
func selecting():
	if actor_existing_tiles.has(mouse_coord):
		var actor : Actor = actor_existing_tiles[mouse_coord]
		if actor is Unit or actor is Structure:
			change_state(State.PLAYER_ACTOR_SELECTED)
		
		selected_actor = actor
	
	else:
		selected_actor = null

func set_selected_actor(actor : Actor):
	if selected_actor:
		selected_actor.selected = false
	
	selected_actor = actor
	
	if actor:
		selected_id.text = actor.data.id
		selected_portrait.texture = actor.data.sprite
		selected_info.show()
		
		if actor is Unit or actor is Structure:
			actor.selected = true
			eliminate_button.show()
			
			if actor is Unit:
				move_button.show()
				attack_button.show()
				move_button.disabled = not actor.is_move_remain
				attack_button.disabled = not actor.is_attack_remain
			else:
				move_button.hide()
				if actor is ActableStructure:
					attack_button.show()
					attack_button.disabled = not actor.is_attack_remain
				else:
					attack_button.hide()
		else:	# enemy.
			move_button.hide()
			attack_button.hide()
			eliminate_button.hide()
	else:
		current_commandable_coords.clear()
		selected_info.hide()

func commanding_move():
	actor_existing_tiles.erase(selected_actor.cur_coord)
	actor_existing_tiles[mouse_coord] = selected_actor
	
	on_acting = true
	selected_actor.move_command(mouse_coord)
	
	change_state(State.BASIC)

func commanding_attack():
	on_acting = true
	selected_actor.attack_command(mouse_coord)
	
	change_state(State.BASIC)

func after_action(actor : Actor):
	change_state(State.PLAYER_ACTOR_SELECTED)
	
	on_acting = false
	selected_actor = actor

func manage_movable_tiles(coord : Vector2i, ran : int):
	current_commandable_coords = get_surrounding_tiles(coord, ran).filter(
		func(elem : Vector2i):
			return current_painted_tiles.has(elem) and not actor_existing_tiles.has(elem)
	)
	
	focus.show_move_reach(current_commandable_coords)

func manage_attackable_tiles(coord : Vector2i, ran : int):
	current_commandable_coords = get_straight_tiles(coord, ran)
	
	focus.show_attack_reach(current_commandable_coords)

#endregion

#region About Enemy
func add_enemy(enemy : Enemy):
	actor_existing_tiles[enemy.cur_coord] = enemy

func erase_enemy(actor : Actor):
	actor_existing_tiles.erase(actor.cur_coord)

func move_enemy(enemy : Enemy, coord : Vector2i):
	actor_existing_tiles.erase(enemy.cur_coord)
	actor_existing_tiles[coord] = enemy

func attack_enemy(coord : Vector2i, damage : int, arm_pen : bool):
	actor_existing_tiles[coord].take_damage(damage, arm_pen)
#endregion

#region About Calling
# when click armament call of call table.
func call_prepare(armament_call : ArmamentCall):
	prepared_armament = armament_call
	change_state(State.CALLING)

func calling():
	var armament := prepared_armament.data.armament.instantiate()
	armament.data = prepared_armament.data
	armament.position = map_to_local(mouse_coord)
	
	if armament is Unit or armament is Structure:
		armament.cur_coord = mouse_coord
		actor_existing_tiles[mouse_coord] = armament
		armament.died.connect(actor_eliminated)
		armament.act_ended.connect(after_action)
		
		if armament is Unit:
			total_used_count += armament.data.tile_cost
			add_unit_by_priority(armament)
			units.add_child(armament)
		else:
			structures.add_child(armament)
	else:
		weapons.add_child(armament)
		armament.weapon_effect(mouse_coord)
	
	prepared_armament.after_call()
	consume_ink(armament.data.ink_cost)
	
	change_state(State.BASIC)

#endregion

#region About Painting and Tile Handling
func get_ink_resource():
	ink += total_painted_count * ink_earning_per_tile

func paint_prepare():
	change_state(State.PAINTING)

func painting():
	consume_ink(paint_call.paint_cost)
	paint_tile(mouse_coord)
	
	if ink < paint_call.paint_cost:
		change_state(State.BASIC)

func paint_tile(coord : Vector2i):
	set_cell(coord, 0, Vector2i.ZERO)
	current_painted_tiles[coord] = tile_max_health
	total_painted_count += 1
	
	tile_painted.emit(coord)

func erase_tile(coord : Vector2i):
	erase_cell(coord)
	current_painted_tiles.erase(coord)
	total_painted_count -= 1
	
	tile_erased.emit(coord)
	
	if actor_existing_tiles.has(coord):
		actor_existing_tiles[coord].death()

func hit_tile(coord : Vector2i, amount : int):
	current_painted_tiles[coord] -= amount
	
	if current_painted_tiles[coord] < 0:
		erase_tile(coord)

func get_straight_tiles(coord : Vector2i, ran : int) -> Array[Vector2i]:
	var ran_arr := range(1, ran + 1)
	var coord_arr : Array[Vector2i] = []
	
	for i in ran_arr:
		coord_arr.append(Vector2i(coord.x + i, coord.y))
		coord_arr.append(Vector2i(coord.x - i, coord.y))
		coord_arr.append(Vector2i(coord.x, coord.y + i))
		coord_arr.append(Vector2i(coord.x, coord.y - i))
	
	return coord_arr.filter(coord_checker)

func get_surrounding_tiles(coord : Vector2i, ran : int) -> Array[Vector2i]:
	var ran_arr := range(-ran, ran + 1)
	var coord_arr : Array[Vector2i]
	
	for i in ran_arr:
		for j in ran_arr:
			if absi(i) + absi(j) <= ran:
				coord_arr.append(coord + Vector2i(i,j))
	
	return coord_arr.filter(coord_checker)

func coord_checker(coord : Vector2i) -> bool:
	return absi(coord.x) <= MAP_WIDTH and absi(coord.y) <= MAP_WIDTH

func find_closest_tile_coord(pos : Vector2) -> Vector2:
	var closest_pos := Vector2i.ZERO
	var closest_dist := INF
	
	for painted_coord in current_painted_tiles.keys():
		var painted_pos := map_to_local(painted_coord)
		var dist := pos.distance_squared_to(painted_pos)
		
		if dist < closest_dist:
			closest_pos = painted_pos
			closest_dist = dist
	
	return closest_pos
#endregion

#region Add and Eliminate
func add_unit_by_priority(unit : Unit):
	for i in eliminate_priority_queue.size():
		if eliminate_priority_queue[i].data.tier >= unit.data.tier:
			eliminate_priority_queue.insert(i, unit)
			return
	
	eliminate_priority_queue.append(unit)

func actor_eliminated(actor : Actor):
	actor_existing_tiles.erase(actor.cur_coord)
	
	if actor is Unit:
		eliminate_priority_queue.erase(actor)
		total_used_count -= actor.data.tile_cost
	elif true: #actor is Structure:
		pass
	else:
		return

func eliminate_unit_in_queue(amount : int):
	var elapsed := 0
	var eliminate_list : Array[Unit] = []
	
	for unit in eliminate_priority_queue:
		elapsed += unit.data.tile_cost
		eliminate_list.append(unit)
		
		if elapsed >= amount:
			break
	
	for unit in eliminate_list:
		unit.death()

#endregion

#region Signal Connected Methods
func move_button_clicked():
	is_move_command = true
	manage_movable_tiles(selected_actor.cur_coord, selected_actor.data.mobility)

func attack_button_clicked():
	is_move_command = false
	manage_attackable_tiles(selected_actor.cur_coord, selected_actor.data.reach)

func eliminate_button_clicked():
	selected_actor.death()
	
	change_state(State.BASIC)

func upgrade_button_clicked():
	consume_ink(upgrade_cost[base_tier])
	
	base_tier += 1
	if base_tier == upgrade_cost.size():
		upgrade_button.hide()
	
	check_armament_calls.emit()

#endregion
