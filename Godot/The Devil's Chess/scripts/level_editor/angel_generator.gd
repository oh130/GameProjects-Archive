extends Button

@export var piece_type : int

func init_generator(_piece_type : int):
	piece_type = _piece_type
	icon = Global.enemy_textures[piece_type]
