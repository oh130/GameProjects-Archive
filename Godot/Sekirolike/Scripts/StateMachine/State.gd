class_name State extends Node

@export var can_move : bool
@export var can_flip : bool

# this will be declared by StateMachine.
var character : CharacterBody2D
var playback : AnimationNodeStateMachinePlayback
# it will be declared by each states. 
var next_state : State

signal interrupt_state(new_state : State)

func state_process(delta):
	pass

func state_input(event : InputEvent):
	pass 

func on_enter():
	pass
	
func on_exit():
	pass
