class_name BoardObject extends Sprite2D

var table : Node2D

@export var coord : Vector2i :
	set(value):
		coord = value
		position = Global.get_pos_by_coord(coord)
		
		if not is_node_ready():
			await ready
		table.cell_obj_checker[coord.y][coord.x] = self

const outline_shader : Shader = preload("res://resources/shader/outline_shader.gdshader")

func _ready():
	table = get_tree().root.find_child("Table", true, false)
	
	if self is Enemy:
		self.devil_died.connect(table.devil_killed)

func _on_area_2d_mouse_entered():
	material.shader = outline_shader

func _on_area_2d_mouse_exited():
	material.shader = null
