class_name Actor extends Node2D

const UNIT_OUTLINE_COLOR := Color.GREEN
const ENEMY_OUTLINE_COLOR := Color.RED

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var cur_coord : Vector2i

var selected := false :
	set(value):
		selected = value
		if selected:
			sprite_2d.material.set("shader_parameter/width", 1)
		else:
			sprite_2d.material.set("shader_parameter/width", 0)

var dead := false

signal act_ended(actor : Actor)
signal died(actor : Actor)

func _ready():
	sprite_2d.material.set("shader_parameter/width", 0)

func death():
	dead = true
	died.emit(self)
	animation_player.play("death")

func after_appear():
	animation_player.play("idle")

func after_death():
	queue_free()

func act_end():
	animation_player.play("idle")
	act_ended.emit(self)
