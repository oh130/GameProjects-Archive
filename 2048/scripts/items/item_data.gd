class_name ItemData extends Resource

enum EffectID
{
	BROKEN_BLADE,
	STEELHEART,
	PIGGY_BANK
}

# type which time item affects.
enum Type
{
	START_OF_COMBAT,
	END_OF_COMBAT
}

@export_group("Information")
@export var id : String
@export var icon : Texture
@export_multiline var description : String

@export_group("In Game")
@export var effect_id : EffectID
@export var type : Type

func effect():
	match effect_id:
		EffectID.BROKEN_BLADE:
			# card deleted
			GameManager.enemy.take_damage(1)
		EffectID.STEELHEART:
			# start of combat
			GameManager.player.heal(2)
