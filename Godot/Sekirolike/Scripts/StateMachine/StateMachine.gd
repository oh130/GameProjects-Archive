class_name StateMachine extends Node

@export var character : CharacterBody2D
@export var animation_tree : AnimationTree
@export var current_state : State

var states : Array[State]

func _ready():
	for child in get_children():
		# insert all states at array 'states'.
		if child is State:
			states.append(child)
			child.character = character
			child.playback = animation_tree["parameters/playback"]
			
			# connect signal: interrupt state.
			child.connect("interrupt_state", on_state_interrupt_state)
			
		else:
			push_warning("Child " + child.name + " is not a State")

func _physics_process(delta):
	# continuous check current state's next state, if exist, change to next state.
	if current_state.next_state != null:
		switch_states(current_state.next_state)
	# after changing, proceed current state's state_process.
	current_state.state_process(delta)

func switch_states(new_state : State):
	if current_state != null:
		current_state.on_exit()
		current_state.next_state = null
	
	current_state = new_state
	current_state.on_enter()
	
func _input(event : InputEvent):
	# transfer input.
	current_state.state_input(event)

func on_state_interrupt_state(new_state : State):
	#change state to new(interrupting) state.
	switch_states(new_state)
