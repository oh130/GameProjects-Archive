class_name AirState extends State

@export var action_mediator : ActionMediator
@export var ground_state : State

var has_double_jumped = false

func state_process(delta):
	if character.is_on_floor():
		next_state = ground_state

func state_input(event : InputEvent):
	if event.is_action_pressed("jump") and not has_double_jumped:
		has_double_jumped = true
		next_state = action_mediator.jump()
	elif event.is_action_pressed("attack"):
		next_state = action_mediator.attack()
	elif event.is_action_pressed("parry"):
		next_state = action_mediator.parry()	
	elif event.is_action_pressed("dash"):
		next_state = action_mediator.dash()

func on_exit():
	if next_state == ground_state:
		playback.travel("move")
