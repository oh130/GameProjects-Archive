class_name CustomButton extends Button

const DEFAULT_UI_CLICK_SFX := preload("res://resources/fxs/audio/sfx/ui/click.wav")

@onready var under_texture: TextureRect = %UnderTexture

@export var click_sfx : AudioStream = DEFAULT_UI_CLICK_SFX

func _ready():
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	pressed.connect(on_pressed)

func on_mouse_entered():
	var tween := create_tween()
	tween.tween_property(under_texture.material, "shader_parameter/transition", 0.5, 0.3)

func on_mouse_exited():
	var tween := create_tween()
	tween.tween_property(under_texture.material, "shader_parameter/transition", 0, 0.3)

func on_pressed():
	Audio.play_sfx(click_sfx)
	
	var tween := create_tween()
	tween.set_parallel(false)
	tween.tween_property(under_texture.material, "shader_parameter/transition", 1, 0.1)
	tween.tween_property(under_texture.material, "shader_parameter/transition", 0.5, 0.2)
