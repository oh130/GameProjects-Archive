extends Node

enum DmgType {
	EG,
	AD,
	AP,
	PR
}

enum Stat {
	HEALTH,
	ENERGY,
	SHIELD,
	AD,
	AP,
	ARM,
	MAG_RES,
	CRIT,
	CRIT_DMG,
	SPEED,
	DODGE,
	ACCURACY,
	VAMP,
	VIGOR,
	MOVE_RES,
	ARM_PEN,
	ARM_PEN_PER,
	MAG_PEN,
	MAG_PEN_PER
}

enum SE{
	BUFF,
	DEBUFF,
	MARKED,
	EXHAUSTED,
	RIPOSTE,
	ASSIST,
	GUARD,
	BE_GUARDED,
	STEALTH,
	CONCENTRATION
}

enum PlayableCharacter{
	ORC,
	ELF,
}

enum MapEvents{
	NOTHING,
	COMBAT,
}

var EMPTY : String = ""
