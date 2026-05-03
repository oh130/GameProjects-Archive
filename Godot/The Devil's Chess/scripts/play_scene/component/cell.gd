extends Button

@export var coord : Vector2i

func _ready():
	set_disable()

func set_able():
	disabled = false
	modulate.a = 255

func set_disable():
	disabled = true
	modulate.a = 0
