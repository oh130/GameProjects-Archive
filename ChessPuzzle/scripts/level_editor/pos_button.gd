extends Button

@export var enemy_exist : bool
@export var coord : Vector2i
@export var piece_type : int

func _ready():
	inactive_self()

func init_coord(_coord : Vector2i):
	coord = _coord

func set_to_enemy():
	piece_type = get_parent().selected_piece_type
	icon = Global.enemy_textures[piece_type]
	enemy_exist = true

func active_self():
	modulate.a = 255
	disabled = false

func inactive_self():
	enemy_exist = false
	modulate.a = 0
	disabled = true
	icon = null
