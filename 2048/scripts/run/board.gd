class_name Board extends Control

enum PropertyID
{
	ATTACK,
	DEFENSE,
	SELF_HARM,
	SELF_HEAL,
	ENEMY_HEAL,
	ENEMY_ACCEL,
	ENEMY_DECEL,
	DOUBLE,
	TRIPLE,
	QUADRAPLE,
}
const ELEMENT_SCENE := preload("res://scenes/run/element.tscn")
const BOARD_SIZE := 4
const DIRECTIONS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

@onready var data_manager: DataManager = %DataManager
@onready var elements: Control = %Elements
@onready var buttons: Control = %Buttons

var board_state : Array[Array]
var instant_element : ElementData

signal game_over()

func _ready():
	GameManager.board = self
	
	var i : int = 0
	for button : Button in buttons.get_children():
		button.pressed.connect(create_instant_element.bind(
			Vector2i(i % BOARD_SIZE, i / BOARD_SIZE)))
		i += 1
	
	buttons.hide()

func init_board():
	for i in BOARD_SIZE:
		var temp : Array[Element]
		for j in BOARD_SIZE:
			temp.append(null)
		board_state.append(temp)
	
	if not is_node_ready():
		await ready
	
	spawn_element_randomly()

func load_board(saved_board_state : Array[Array]):
	for i in BOARD_SIZE:
		var temp : Array[Element]
		for j in BOARD_SIZE:
			temp.append(null)
		board_state.append(temp)
	
	if not is_node_ready():
		await ready
	
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var elem : Element = saved_board_state[j][i]
			if elem == null:
				continue
			
			var inst := ELEMENT_SCENE.instantiate()
			elements.add_child(inst)
			inst.load_element(elem)
			
			board_state[j][i] = inst

func property_effect(property : Property, stacked_amount := 0):
	match property.property_id:
		PropertyID.ATTACK:
			GameManager.enemy.take_damage(stacked_amount)
		PropertyID.DEFENSE:
			GameManager.player.get_armor(stacked_amount)
		PropertyID.SELF_HARM:
			GameManager.player.take_damage(stacked_amount)
		PropertyID.SELF_HEAL:
			GameManager.player.heal(stacked_amount)
		PropertyID.ENEMY_HEAL:
			GameManager.enemy.heal(stacked_amount)
		PropertyID.ENEMY_ACCEL:
			GameManager.enemy.action_remain_tick -= 1
		PropertyID.ENEMY_DECEL:
			GameManager.enemy.action_remain_tick += 1

func _physics_process(_delta: float) -> void:
	if not GameManager.on_combat:
		return
	
	var dir := Vector2i.ZERO
	if Input.is_action_just_pressed("ui_left"):
		dir = Vector2i.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		dir = Vector2i.RIGHT
	elif Input.is_action_just_pressed("ui_up"):
		dir = Vector2i.UP
	elif Input.is_action_just_pressed("ui_down"):
		dir = Vector2i.DOWN
	
	if dir != Vector2i.ZERO and check_possible_move(dir):
		handle_move(dir)
		spawn_element_randomly()
		
		if check_game_over():
			print(123)
			game_over.emit()

func spawn_element_randomly():
	if is_board_full():
		return
	
	while true:
		var coord := Vector2i(randi_range(0, BOARD_SIZE - 1), randi_range(0, BOARD_SIZE - 1))
		if board_state[coord.x][coord.y] == null:
			create_element_on_board(data_manager.pick_element_randomly(), coord)
			return

func create_element_on_board(element_data : ElementData, coord : Vector2i):
	var inst := ELEMENT_SCENE.instantiate()
	elements.add_child(inst)
	inst.init_element(element_data)
	inst.created_on_board(coord)
	board_state[coord.x][coord.y] = inst

func prefare_instant_element(element_data : ElementData):
	var i : int = 0
	for button : Button in buttons.get_children():
		if board_state[i % BOARD_SIZE][i / BOARD_SIZE] == null:
			button.show()
		else:
			button.hide()
		i += 1
	
	buttons.show()
	
	instant_element = element_data

func create_instant_element(coord : Vector2i):
	buttons.hide()
	EventBus.reward_selected.emit()
	
	create_element_on_board(instant_element, coord)

func check_coord(coord : Vector2i) -> bool:
	return coord.x >= 0 and coord.x < BOARD_SIZE and coord.y >= 0 and coord.y < BOARD_SIZE

func is_board_full() -> bool:
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			if board_state[j][i] == null:
				return false
	return true

func check_game_over() -> bool:
	if not is_board_full():
		return false
	
	for dir in DIRECTIONS:
		if check_possible_move(dir):
			return false
	
	return true

func check_possible_move(dir: Vector2i) -> bool:
	var row := range(0, BOARD_SIZE)
	var col := range(0, BOARD_SIZE)
	
	match dir:
		Vector2i.DOWN:
			row.reverse()
		Vector2i.RIGHT:
			col.reverse()
	
	for i in row:
		for j in col:
			var elem : Element = board_state[j][i]
			if elem == null:
				continue
			
			var cur_pos := Vector2i(j,i)
			while true:
				cur_pos += dir
				if not check_coord(cur_pos):
					break
				var elem_to : Element = board_state[cur_pos.x][cur_pos.y]
				
				if elem_to != null:
					if elem.grade == elem_to.grade:
						return true
					else:
						break
				else:
					return true
	
	return false

func handle_move(dir : Vector2i):
	var row := range(0, BOARD_SIZE)
	var col := range(0, BOARD_SIZE)
	
	match dir:
		Vector2i.DOWN:
			row.reverse()
		Vector2i.RIGHT:
			col.reverse()
	
	var pairs : Dictionary[Element, Element]
	
	for i in row:
		for j in col:
			var elem : Element = board_state[j][i]
			if elem == null:
				continue
			
			var cur_pos := Vector2i(j,i)
			while true:
				cur_pos += dir
				if not check_coord(cur_pos):
					break
				var elem_to : Element = board_state[cur_pos.x][cur_pos.y]
				if elem_to != null:
					if elem.grade == elem_to.grade:
						if not pairs.has(elem_to) and not pairs.values().has(elem_to):
							pairs[elem] = elem_to
					else:
						break
	
	for i in row:
		for j in col:
			if board_state[j][i] != null:
				move_elem_to_dir(board_state[j][i], dir)
	
	for elem : Element in pairs.keys():
		board_state[elem.cur_coord.x][elem.cur_coord.y] = null
	
	# before combine, save all property effects.
	var property_arr : Array[Property]
	var stacked_amount_arr : Array[int]
	
	for elem : Element in pairs.keys():
		for prop in elem.properties:
			property_arr.append(prop)
			stacked_amount_arr.append(elem.properties[prop])
		for prop in pairs[elem].properties:
			property_arr.append(prop)
			stacked_amount_arr.append(pairs[elem].properties[prop])
	
	for elem : Element in pairs.keys():
		elem.combined_at(pairs[elem])
	
	# after combine, affect.
	for i in property_arr.size():
		var prop := property_arr[i]
		if prop.stackable:
			property_effect(prop, stacked_amount_arr[i])
		else:
			property_effect(prop)
		
		await get_tree().create_timer(0.1).timeout
	
	EventBus.commanded.emit()

func move_elem_to_dir(elem : Element, dir : Vector2i):
	var next_coord : Vector2i = elem.cur_coord + dir
	while check_coord(next_coord) and board_state[next_coord.x][next_coord.y] == null:
		next_coord += dir
	next_coord -= dir
	
	if elem.cur_coord == next_coord:
		return
	
	board_state[elem.cur_coord.x][elem.cur_coord.y] = null
	board_state[next_coord.x][next_coord.y] = elem
	elem.move_to(next_coord)
