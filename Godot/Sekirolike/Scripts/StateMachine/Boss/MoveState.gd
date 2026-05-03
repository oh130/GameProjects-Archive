class_name MoveState extends State

@onready var attack_timer : Timer = get_child(0)

@export var attack_state : State
@export var awakening_state : State
@export var double_attack_state : State

var awaken : bool = false
var is_player_in_attack_range : bool = false

func state_process(delta):
	if is_player_in_attack_range and attack_timer.is_stopped():
		if awaken:
			if randf() < 0.4:
				next_state = double_attack_state
				playback.travel("double_attack")
			else:
				next_state = attack_state
				playback.travel("attack")
		else:
			next_state = attack_state
			playback.travel("attack")
			
		attack_timer.start()

func _on_detect_box_body_entered(body):
	if body.name == "Player":
		is_player_in_attack_range = true


func _on_detect_box_body_exited(body):
	if body.name == "Player":
		is_player_in_attack_range = false
