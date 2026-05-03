extends TextureRect

var property : Dictionary = {
	"texture" : texture,
	"unit_name" : Enum.EMPTY
}:
	set(value):
		property = value
		texture = property["texture"]

var is_const : bool = true

func _get_drag_data(at_position):
	var preview_texture = TextureRect.new()
	
	preview_texture.texture = texture
	preview_texture.expand_mode = 1
	preview_texture.size = size
	
	var preview = Control.new()
	preview.add_child(preview_texture)
 
	set_drag_preview(preview)
 
	return self

func _can_drop_data(at_position, data):
	return false
