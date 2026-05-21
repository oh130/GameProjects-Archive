class_name UnitData extends Resource

const MUST_HAVE_STAT_KEYS : Array[Enum.Stat] =\
[
	Enum.Stat.LEVEL,
	Enum.Stat.POWER,
	
	Enum.Stat.MAX_HEALTH,
	Enum.Stat.MAX_ENERGY,
	Enum.Stat.STRENGTH,
	Enum.Stat.INTELLIGENCE,
	Enum.Stat.DEXTERITY,
	Enum.Stat.FAITH,
	Enum.Stat.CRIT,
	Enum.Stat.CRIT_MUL,
	Enum.Stat.ARMOR,
	Enum.Stat.DODGE,
	Enum.Stat.ARMOR_PEN,
	Enum.Stat.ARMOR_PEN_RATE,
	
	Enum.Stat.COUNTER_CHANCE,
	Enum.Stat.ASSIST_CHANCE,
	Enum.Stat.COUNTER_DMG_AMP,
	Enum.Stat.ASSIST_DMG_AMP,
	
	Enum.Stat.RESILIENCE,
	Enum.Stat.ADD_ENERGY_REG,
	
	Enum.Stat.IMPACT_AMP,
	Enum.Stat.SLASH_AMP,
	Enum.Stat.PIERCE_AMP,
	Enum.Stat.NATURE_AMP,
	Enum.Stat.ARCANE_AMP,
	Enum.Stat.MYSTIC_AMP,
	Enum.Stat.ENERGY_DMG_AMP,
	Enum.Stat.TAKE_DMG_AMP,
	Enum.Stat.GAIN_EXP_AMP,
]

@export_group("Information(Should Pre-Set)")
@export var sprite : Texture2D
@export var stats : Dictionary[Enum.Stat, Amount]
@export var stat_up_per_level : Dictionary[Enum.Stat, float] =\
{
	Enum.Stat.LEVEL : 1,
}
@export var skills : Array[Skill]

@export_group("In-Game Variables(Don't Touch)")
@export var passives : Array[Passive]
@export var applied_stats : Dictionary[Enum.Stat, int]
@export var health : int : set = set_health
@export var energy : int : set = set_energy
@export var shield : int : set = set_shield

signal health_changed(val : int)
signal energy_changed(val : int)
signal shield_changed()

func initialize():
	# init health and energy.
	applied_stats[Enum.Stat.MAX_HEALTH] = roundi(stats[Enum.Stat.MAX_HEALTH].amount)
	applied_stats[Enum.Stat.MAX_ENERGY] = roundi(stats[Enum.Stat.MAX_ENERGY].amount)
	health = applied_stats[Enum.Stat.MAX_HEALTH]
	energy = applied_stats[Enum.Stat.MAX_ENERGY]
	
	for stat in MUST_HAVE_STAT_KEYS:
		if not stats.has(stat):
			stats[stat] = Amount.new()

func set_health(value : int):
	health = clampi(value, 0, applied_stats[Enum.Stat.MAX_HEALTH])
	health_changed.emit(health)

func set_energy(value : int):
	energy = clampi(value, 0, applied_stats[Enum.Stat.MAX_ENERGY])
	energy_changed.emit(energy)

func set_shield(value : int):
	shield = value
	shield_changed.emit()
