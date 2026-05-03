extends Sprite2D

func _ready():
	ghosting()

func set_sprite(_texture : Texture, h_frame : int, _frame : int, flip : bool):
	texture = _texture
	hframes = h_frame
	frame = _frame
	flip_h = flip

func set_pos(pos : Vector2):
	position = pos
	position.y -= 25
	
func ghosting():
	var tween_fade = get_tree().create_tween()
	
	tween_fade.tween_property(self, "self_modulate", Color(1,1,1,0), 0.15)
	await tween_fade.finished
	
	queue_free()
