class_name GroundState extends State

@export var action_mediator : ActionMediator
@export var air_state : AirState

func state_process(delta):
	air_state.has_double_jumped = false
	
	if not character.is_on_floor():
		next_state = air_state
		playback.travel("fall")

func state_input(event : InputEvent):
	if event.is_action_pressed("jump"):
		next_state = action_mediator.jump()
	elif event.is_action_pressed("attack"):
		next_state = action_mediator.attack()
	elif event.is_action_pressed("parry"):
		next_state = action_mediator.parry()	
	elif event.is_action_pressed("dash"):
		next_state = action_mediator.dash()
