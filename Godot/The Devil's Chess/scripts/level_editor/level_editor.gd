extends Node2D

@onready var devil = $Devil
@onready var cell_container = $CellContainer
@onready var sacrifice_container = $SacrificeContainer
@onready var pos_button_container = $PosButtonContainer
@onready var sg_container = $UI/SGContainer

@onready var chapter_text = $UI/ChapterText
@onready var level_text = $UI/LevelText

@export var cell_obj_checker : Array[Array]

func _ready():
	refresh_custom_level()

func refresh_custom_level():
	pos_button_container.clear_pos_buttons()
	sg_container.refresh_all_generator()
	
	cell_obj_checker.clear()
	cell_obj_checker.resize(8)
	for i in 8:
		cell_obj_checker[i].resize(8)
		for j in 8:
			cell_obj_checker[i][j] = Global.null
	
	cell_container.board_cell_hide_all()

func export_custom_level_as():
	var enemies : Array[Dictionary]
	var obstacles : Dictionary
	var sacrifices : Dictionary
	var custom_level_info : Dictionary
	
	for child in sg_container.get_children():
		sacrifices[str(child.sac_type)] = child.count
	
	for child in pos_button_container.get_children():
		if child.enemy_exist:
			enemies.append({"pos" : [child.coord.x, child.coord.y], "type" : child.piece_type})
	
	custom_level_info["enemies"] = enemies
	custom_level_info["obstacles"] = obstacles
	custom_level_info["sacrifices"] = sacrifices
	
	if not Level.level_info.has(chapter_text.text):
		Level.level_info[chapter_text.text] = {}
	Level.level_info[chapter_text.text][level_text.text] = custom_level_info
	Level.write_level_info_file()

func change_cell_obj_checker(cell_coord : Vector2i, obj_type : int):
	cell_obj_checker[cell_coord.y][cell_coord.x] = obj_type

#func check_algorithm():
	#var queue : Array[Dictionary] = []
	#queue.append({"devil_pos" : Global.devil_origin, "sacrifices" : cur_sacrifice_state, "obj_check" : cur_board_state, "procedure" : []})
	#
	#var loop_count : int = 0
	#var solve_depth : int = (1<<31) - 1
	#var procedure_arr : Array[Array] = []
	#
	#var tot_sacrifice_count : int = 0
	#for i in cur_sacrifice_state.values():
		#tot_sacrifice_count += i
	#
	#while not queue.is_empty():
		#loop_count += 1
		#print(loop_count)
		#
		#var cur : Dictionary = queue.pop_front()
		#var cur_devil_pos : Vector2i = cur["devil_pos"]
		#var cur_sacrifices : Dictionary = cur["sacrifices"]
		#var cur_obj_check : Array[Array] = cur["obj_check"]
		#var cur_procedure : Array = cur["procedure"]
		#
		#if cur_procedure.size() > solve_depth:
			#break
		#
		#var sacrifice_count : int = 0
		#var enemy_count : int = 0
		#
		#for key in cur_sacrifices.keys():
			#if cur_sacrifices[key] == 0:
				#cur_sacrifices.erase(key)
			#else:
				#sacrifice_count += cur_sacrifices[key]
		#
		#for i in cur_obj_check:
			#for j in i:
				#if j == Global.OBJ_TYPE.enemy:
					#enemy_count += 1
		#
		#if enemy_count == 0:
			#print(cur_obj_check)
			#solve_depth = min(solve_depth, cur_procedure.size())
			#if cur_procedure not in procedure_arr:
				#procedure_arr.append(cur_procedure)
			#continue
		#elif enemy_count > sacrifice_count:
			#continue
		#
		#for key in cur_sacrifices.keys():
			#var temp_sacrifices : Dictionary = cur_sacrifices.duplicate(true)
			#var temp_procedure : Array = cur_procedure.duplicate(true)
			#
			#temp_sacrifices[key] -= 1
			#temp_procedure.push_back(key)
			#
			#var movable_cells : Array[Vector2i] = Global.get_sacrifice_effect_pos(cur_devil_pos, key, cur_obj_check)
			#for coord in movable_cells:
				#var temp_obj_check : Array[Array] = cur_obj_check.duplicate(true)
				#var enemy_existed : bool = (temp_obj_check[coord.y][coord.x] == Global.OBJ_TYPE.enemy)
				#
				#if not enemy_existed and enemy_count == sacrifice_count:
					#continue
				#
				#temp_obj_check[cur_devil_pos.y][cur_devil_pos.x] = Global.null
				#temp_obj_check[coord.y][coord.x] = Global.OBJ_TYPE.DEVIL
				#
				#queue.append({"devil_pos" : coord, "sacrifices" : temp_sacrifices, "obj_check" : temp_obj_check, "procedure" : temp_procedure})
	#
	#if solve_depth < tot_sacrifice_count:
		#is_possible.text = "Remained"
	#elif solve_depth == tot_sacrifice_count:
		#is_possible.text = "Possible"
	#else:
		#is_possible.text = "Impossible"
	#
	#for procedure in procedure_arr:
		#var seq = seq_scene.instantiate()
		#sequences.add_child(seq)
		#for piece in procedure:
			#var sac : TextureRect = sac_portrait.instantiate()
			#seq.add_child(sac)
			#sac.texture = Global.sacrifice_textures[piece]
