extends CanvasLayer

func create_vfx(vfx : VFX, pos : Vector2):
	var sprite := Sprite2D.new()
	add_child(sprite)
	sprite.position = pos
	sprite.texture = vfx.texture
	sprite.hframes = vfx.hframes
	sprite.vframes = vfx.vframes
	
	for i in vfx.frame_count:
		sprite.frame = i
		await get_tree().process_frame
	
	sprite.queue_free()
