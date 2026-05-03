class_name RosterIcon extends TextureRect

var property : Dictionary = {
	"texture" : null,
	"unit_name" : Enum.EMPTY
}:
	set(value):
		property = value
		texture = property["texture"]

var roster_squares : Array[Node]

var is_const : bool = false
var on_dragging : bool = false

func _ready():
	roster_squares = get_parent().get_children()

func _get_drag_data(at_position):
	var preview_texture = TextureRect.new()
	
	preview_texture.texture = texture
	preview_texture.expand_mode = 1
	preview_texture.size = size
 
	set_drag_preview(preview_texture)
	texture = null
	on_dragging = true

	return self

func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_END:
			if not is_drag_successful() and on_dragging:
				property = {"texture" : null, "unit_name" : Enum.EMPTY}
			on_dragging = false

func _can_drop_data(at_position, data):
	var can_drop : bool = true
	
	if data.is_const:
		for ch in roster_squares:
			if ch.property["unit_name"] == data.property["unit_name"]:
				can_drop = false
				break
			
	return can_drop and data.property["texture"] != null and data.property["unit_name"] != Enum.EMPTY

func _drop_data(_pos, data):
	if not data.is_const:
		var temp = data.property
		data.property = property
		property = temp
	else:
		property = data.property
