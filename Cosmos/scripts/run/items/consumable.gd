class_name Consumable extends Item

enum Area { ALWAYS, ON_COMBAT, EXCEPT_COMBAT }

@export var area : Area
@export var passives : Array[Passive]

func effect(unit : Player):
	Audio.play_sfx(Audio.consume)
	
	for p in passives:
		p.effect(unit)
