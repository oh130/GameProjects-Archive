class_name Devil extends BoardObject

signal move_end(end_coord : Vector2i)
signal do_voodoo(_piece_type : int)

func init_devil(cur_chap : int, cur_lv : int):
	coord = Vector2i(Level.level_info[str(cur_chap)][str(cur_lv)]["devil_pos"][0],\
		Level.level_info[str(cur_chap)][str(cur_lv)]["devil_pos"][1])

func devil_act(_coord : Vector2i, _chosen_sac : int):
	match _chosen_sac:
		Global.SAC_TYPE.STEALTH:
			await move_animation(_coord)
			
			coord = _coord
			emit_signal("move_end", coord)
		
		Global.SAC_TYPE.TRIDENT:
			await move_animation(_coord)
			
			coord = _coord
			emit_signal("move_end", coord)
		
		Global.SAC_TYPE.JUDGMENT:
			pass
		
		Global.SAC_TYPE.VOODOO:
			pass
		
		Global.SAC_TYPE.DIM_REVERSAL:
			pass
		
		_:
			await move_animation(_coord)
			
			coord = _coord
			emit_signal("move_end", coord)

func move_animation(_coord : Vector2i):
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Global.get_pos_by_coord(_coord), 0.2)

	Global.input_available = false
	await tween.finished
	Global.input_available = true

func get_figure_of_sacrifice(_sac_type : int):
	pass

func get_original_figure():
	pass
