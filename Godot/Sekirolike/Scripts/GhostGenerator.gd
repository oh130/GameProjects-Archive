class_name GhostGenerator extends Node

@export var character : CharacterBody2D
@export var ghost_node : PackedScene
@export var ghost_generate_interval : float
@export var sprite2d : Sprite2D
var custom_timer : float
var active : bool = false

func _physics_process(delta):
	if not active:
		return
	
	custom_timer += delta
	
	if custom_timer >= ghost_generate_interval:
		custom_timer -= ghost_generate_interval
		add_ghost()

func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_pos(character.position)
	ghost.set_sprite(sprite2d.texture, sprite2d.hframes, sprite2d.frame, sprite2d.flip_h)
	get_tree().current_scene.add_child(ghost)
