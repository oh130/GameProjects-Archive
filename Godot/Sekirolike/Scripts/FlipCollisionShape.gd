extends CollisionShape2D

var xPos = transform.origin.x

func _on_player_flip_signal(flip_h):
	if not flip_h:
		transform.origin.x = xPos
	else:
		transform.origin.x = -xPos
