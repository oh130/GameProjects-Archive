extends Node

enum SCENE_TYPE{
	MAIN_MENU,
	LEVEL_MANAGER,
	LEVEL_EDITOR,
	TABLE
}

enum PIECE_TYPE{
	NONE_ATK,
	PAWN,
	KNIGHT,
	BISHOP,
	ROOK,
	QUEEN,
	KING
}

enum SAC_TYPE{
	PAWN,
	KNIGHT,
	BISHOP,
	ROOK,
	KING,
	GOAT,
	STEALTH,
	JUDGMENT,
	KNIGHT_OF_THE_APOCALYPSE,
	TRIDENT,
	VOODOO,
	DIM_REVERSAL
}

const board_mod : Vector2 = Vector2(409,129)
const cell_l : int = 66

const enemy_texture_path = "res://resources/sprites/enemies/"
const sacrifice_texture_path = "res://resources/sprites/sacrifices/"
const statue_texture_path = "res://resources/sprites/statues/"
const halo_texture_path = "res://resources/sprites/halo/"

const straight_dir : Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const diagonal_dir : Array[Vector2i] = [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]
const knight_move_arr : Array[Vector2i] =\
	[Vector2i(2,1), Vector2i(2,-1), Vector2i(-2,1), Vector2i(-2,-1),\
	Vector2i(1,2), Vector2i(1,-2), Vector2i(-1,2), Vector2i(-1,-2)]
const kota_move_arr : Array[Vector2i] =\
	[Vector2i(3,2), Vector2i(3,-2), Vector2i(-3,2), Vector2i(-3,-2),\
	Vector2i(2,3), Vector2i(2,-3), Vector2i(-2,3), Vector2i(-2,-3)]

var enemy_textures : Array[ImageTexture]
var statue_textures : Array[ImageTexture]
var halo_textures : Array[ImageTexture]
var sacrifice_textures : Array[ImageTexture]

var input_available : bool
var fade : ColorRect

func _ready():
	load_textures()

func load_textures():
	var enemy_texture_files : PackedStringArray =  DirAccess.open(enemy_texture_path).get_files()
	var sacrifice_texture_files : PackedStringArray =  DirAccess.open(sacrifice_texture_path).get_files()
	var statue_texture_files : PackedStringArray =  DirAccess.open(statue_texture_path).get_files()
	var halo_texture_files : PackedStringArray =  DirAccess.open(halo_texture_path).get_files()
	
	for file_name in enemy_texture_files:
		if file_name.get_extension() == "import":
			continue
		var texture : Image = Image.new()
		texture.load(enemy_texture_path + file_name)
		enemy_textures.append(ImageTexture.create_from_image(texture))
	
	for file_name in sacrifice_texture_files:
		if file_name.get_extension() == "import":
			continue
		var texture : Image = Image.new()
		texture.load(sacrifice_texture_path + file_name)
		sacrifice_textures.append(ImageTexture.create_from_image(texture))
	
	for file_name in statue_texture_files:
		if file_name.get_extension() == "import":
			continue
		var texture : Image = Image.new()
		texture.load(statue_texture_path + file_name)
		statue_textures.append(ImageTexture.create_from_image(texture))
	
	for file_name in halo_texture_files:
		if file_name.get_extension() == "import":
			continue
		var texture : Image = Image.new()
		texture.load(halo_texture_path + file_name)
		halo_textures.append(ImageTexture.create_from_image(texture))

func get_pos_by_coord(coord : Vector2i) -> Vector2:
	return cell_l * Vector2(coord.x, coord.y) + board_mod

func check_coord(_coord : Vector2i) -> bool:
	return _coord.x >= 0 and _coord.y >= 0 and _coord.x < 8 and _coord.y < 8

func show_node_by_tween(target_node : Control):
	target_node.show()
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(target_node, "modulate:a", 1, 0.2)
	await tween.finished

func hide_node_by_tween(target_node : Control):
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(target_node, "modulate:a", 0, 0.2)
	await tween.finished
	target_node.hide()

func fade_in():
	await hide_node_by_tween(fade)
	input_available = true

func fade_out():
	input_available = false
	await show_node_by_tween(fade)

func get_sacrifice_effect_pos(devil_coord : Vector2i, _sac_type : int, obj_check : Array[Array]) -> Array[Vector2i]:
	var movable_cell_coords : Array[Vector2i] = []
	
	match _sac_type:
		SAC_TYPE.PAWN:
			var up : Vector2i = devil_coord + Vector2i(0,-1)
			var up_left : Vector2i = devil_coord + Vector2i(-1,-1)
			var up_right : Vector2i = devil_coord + Vector2i(1,-1)
			
			if check_coord(up) and obj_check[up.y][up.x] == null:
				movable_cell_coords.append(up)
			if check_coord(up_left) and not (obj_check[up_left.y][up_left.x] == null\
			 or obj_check[up_left.y][up_left.x] is Statue):
				movable_cell_coords.append(up_left)
			if check_coord(up_right) and not (obj_check[up_right.y][up_right.x] == null\
			 or obj_check[up_right.y][up_right.x] is Statue):
				movable_cell_coords.append(up_right)
				
		SAC_TYPE.KNIGHT:
			for move in knight_move_arr:
				var _coord : Vector2i = devil_coord + move
				if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
					movable_cell_coords.append(_coord)
		
		SAC_TYPE.BISHOP:
			for dir in diagonal_dir:
				for i in range(1,8):
					var _coord : Vector2i = devil_coord + dir * i
					if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
						movable_cell_coords.append(_coord)
						if obj_check[_coord.y][_coord.x] != null:
							break
					else:
						break
		
		SAC_TYPE.ROOK:
			for dir in straight_dir:
				for i in range(1,8):
					var _coord : Vector2i = devil_coord + dir * i
					if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
						movable_cell_coords.append(_coord)
						if obj_check[_coord.y][_coord.x] != null:
							break
					else:
						break
		
		SAC_TYPE.KING:
			for dir in straight_dir:
				var _coord : Vector2i = devil_coord + dir
				if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
					movable_cell_coords.append(_coord)
			for dir in diagonal_dir:
				var _coord : Vector2i = devil_coord + dir
				if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
					movable_cell_coords.append(_coord)
		
		SAC_TYPE.GOAT:
			for dir in straight_dir:
				var hoppable : bool = false
				for i in range(1,8):
					var _coord : Vector2i = devil_coord + dir * i
					if check_coord(_coord):
						if hoppable and not obj_check[_coord.y][_coord.x] is Statue:
							movable_cell_coords.append(_coord)
						if obj_check[_coord.y][_coord.x] != null:
							hoppable = true
					else:
						break
			
			for dir in diagonal_dir:
				var hoppable : bool = false
				for i in range(1,8):
					var _coord : Vector2i = devil_coord + dir * i
					if check_coord(_coord):
						if hoppable and not obj_check[_coord.y][_coord.x] is Statue:
							movable_cell_coords.append(_coord)
						if obj_check[_coord.y][_coord.x] != null:
							hoppable = true
					else:
						break
			
		SAC_TYPE.KNIGHT_OF_THE_APOCALYPSE:
			for move in kota_move_arr:
				var _coord : Vector2i = devil_coord + move
				if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
					movable_cell_coords.append(_coord)
			
		SAC_TYPE.TRIDENT:
			for dir in straight_dir:
				for i in range(1,8):
					var _coord : Vector2i = devil_coord + dir * i
					if check_coord(_coord):
						movable_cell_coords.append(_coord)
			
			for dir in diagonal_dir:
				for i in range(1,8):
					var _coord : Vector2i = devil_coord + dir * i
					if check_coord(_coord):
						movable_cell_coords.append(_coord)
		
	return movable_cell_coords

func enemy_piece_atk_coords(enemy_coord : Vector2i, _piece_type : int, obj_check : Array[Array]) -> Array[Vector2i]:
	var movable_cell_coords : Array[Vector2i] = []
	
	match _piece_type:
		PIECE_TYPE.PAWN:
			var down_left : Vector2i = enemy_coord + Vector2i(-1,1)
			var down_right : Vector2i = enemy_coord + Vector2i(1,1)
			
			if check_coord(down_left) and not (obj_check[down_left.y][down_left.x] is Statue):
				movable_cell_coords.append(down_left)
			if check_coord(down_right) and not (obj_check[down_right.y][down_right.x] is Statue):
				movable_cell_coords.append(down_right)
				
		PIECE_TYPE.KNIGHT:
			for move in knight_move_arr:
				var _coord : Vector2i = enemy_coord + move
				if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
					movable_cell_coords.append(_coord)
				
		PIECE_TYPE.KING:
			for dir in straight_dir:
				var _coord : Vector2i = enemy_coord + dir
				if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
					movable_cell_coords.append(_coord)
			for dir in diagonal_dir:
				var _coord : Vector2i = enemy_coord + dir
				if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
					movable_cell_coords.append(_coord)
		
		PIECE_TYPE.QUEEN:
			for dir in straight_dir:
				for i in range(1,8):
					var _coord : Vector2i = enemy_coord + dir * i
					if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
						movable_cell_coords.append(_coord)
						if obj_check[_coord.y][_coord.x] != null:
							break
					else:
						break
			for dir in diagonal_dir:
				for i in range(1,8):
					var _coord : Vector2i = enemy_coord + dir * i
					if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
						movable_cell_coords.append(_coord)
						if obj_check[_coord.y][_coord.x] != null:
							break
					else:
						break
		
		PIECE_TYPE.BISHOP:
			for dir in diagonal_dir:
				for i in range(1,8):
					var _coord : Vector2i = enemy_coord + dir * i
					if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
						movable_cell_coords.append(_coord)
						if obj_check[_coord.y][_coord.x] != null:
							break
					else:
						break
		
		PIECE_TYPE.ROOK:
			for dir in straight_dir:
				for i in range(1,8):
					var _coord : Vector2i = enemy_coord + dir * i
					if check_coord(_coord) and not obj_check[_coord.y][_coord.x] is Statue:
						movable_cell_coords.append(_coord)
						if obj_check[_coord.y][_coord.x] != null:
							break
					else:
						break
		
		_:
			pass
		
	return movable_cell_coords
