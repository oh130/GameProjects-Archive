class_name Enemy extends BoardObject

@export var piece_type : int

signal devil_died()

func init_enemy(_enemy_info : Dictionary):
	coord = Vector2i(_enemy_info["pos"][0], _enemy_info["pos"][1])
	piece_type = _enemy_info["type"]
	
	texture = Global.enemy_textures[piece_type]
	
	material.resource_local_to_scene = true

func kill_devil(_coord : Vector2i):
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Global.get_pos_by_coord(_coord), 0.2)
	
	Global.input_available = false
	await tween.finished
	Global.input_available = true
	
	emit_signal("devil_died")
