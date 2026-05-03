class_name ActionMediator extends Node

@onready var character : CharacterBody2D = $"../.."
@onready var animation_tree : AnimationTree = $"../../AnimationTree"
var playback : AnimationNodeStateMachinePlayback

@onready var dash_timer : Timer = $DashCooldown
@onready var attack_timer : Timer = $AttackDelay
@onready var parry_timer : Timer = $ParryDelay

@export var jump_velocity : float

@export var air_state : AirState
@export var attack_state : State
@export var parry_state : State
@export var dash_state : State

var can_attack : bool = true
var can_parry : bool = true
var can_dash : bool = true

func _ready():
	playback = animation_tree["parameters/playback"]
	
func jump() -> State:
	character.velocity.y = jump_velocity
	playback.start("jump")
	return air_state

func attack() -> State:
	if not can_attack:
		return null
	
	can_attack = false
	attack_timer.start()
	
	playback.travel("attack")
	return attack_state

func parry() -> State:
	if not can_parry:
		return null
	
	can_parry = false
	parry_timer.start()
	
	playback.travel("parry")
	return parry_state

func dash() -> State:
	if not can_dash:
		return null
	
	can_dash = false
	dash_timer.start()
	
	playback.travel("dash")
	return dash_state

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_attack_delay_timeout():
	can_attack = true

func _on_parry_delay_timeout():
	can_parry = true
