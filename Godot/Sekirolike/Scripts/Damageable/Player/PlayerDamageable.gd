class_name PlayerDamageable extends Damageable

@export var action_mediator : ActionMediator

var on_parry : bool = false
var on_dash : bool = false
var on_dash_attack : bool = false

func _ready():
	GlobalData.connect("player_hit", hit)

# 나중에 리턴값을 줘서 상대가 상태를 알 수 있게 하자.
func hit():
	if on_dash:
		return
	if on_parry:
		return
	if on_dash_attack:
		return
		
	super.hit()
