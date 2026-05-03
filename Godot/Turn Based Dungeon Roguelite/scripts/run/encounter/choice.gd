class_name Choice extends Resource

enum Type
{
	EXIT,
	# treasure
	RAND_EQUIPMENT,
	RARE_EQUIPMENT,
}

enum Cost
{
	HEALTH
}

@export var type : Type
@export var costs : Dictionary[Cost, int]
@export var description : String
@export var player_specific : String

# equal to check cost.
func check_condition() -> bool:
	var focused_player := DataManager.run.focused_player
	
	for cost in costs:
		match cost:
			Cost.HEALTH:
				if focused_player.data.health < costs[cost]:
					return false
	
	return true

func outcome():
	match type:
		Type.EXIT:
			return
		Type.RAND_EQUIPMENT:
			pass
		Type.RARE_EQUIPMENT:
			pass
