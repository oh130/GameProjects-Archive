class_name Exit extends BoardObject

@onready var halo_container = $"../HaloContainer"

var can_exit : bool = false

signal stage_clear()

func init_exit(cur_chap : int, cur_lv : int):
	coord = Vector2i(Level.level_info[str(cur_chap)][str(cur_lv)]["exit_pos"][0],\
		Level.level_info[str(cur_chap)][str(cur_lv)]["exit_pos"][1])

func check_can_exit():
	if halo_container.get_child_count() == 0:
		can_exit = true
		# open animation

func check_devil_exit(_coord : Vector2i):
	if coord == _coord and can_exit:
		emit_signal("stage_clear")
