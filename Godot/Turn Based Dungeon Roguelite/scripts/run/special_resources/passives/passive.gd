class_name Passive extends Resource
# some passives that simple or hard to separate logics.

enum ID
{
	RESTORE_ALL_HEALTH,
}

@export var id : ID
@export var amount : Amount  # if not use, null.
@export var effect_timing : Enum.Situation

func effect(own_unit : Unit):
	match id:
		pass
