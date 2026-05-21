extends Node

enum Route
{
	ENEMY_MORE_EXP,
	ENEMY_MORE_GOLD,
	ENEMY_MORE_EQUIPMENT,
	ELITE,
	BOSS,
	ENCOUNTER,
	SHOP,
	CHAPTER_ENTER, # It cannot appear at 'next route'.
	CHAPTER_EXIT # It cannot assign at 'current route'.
}

# *NOTE: lower member has lower dialog priority.
enum Situation
{
	# for buff end timing - if none, it is permanent.
	NONE,
	
	# param: chapter.
	CHAPTER_ENTER,
	
	# param: encounter.
	ENCOUNTER_ENTER,
	
	# param: item.
	GET_EQUIPMENT,
	USE_CONSUMABLE,
	
	# param: skill.
	CAST,
	CRIT_CAST,
	
	# sometimes need target param.
	WEAKNESS_ATTACKED,
	COUNTER,
	ASSIST,
	MAKE_SHIELD_BRAKE,
	MAKE_EXHAUST,
	MAKE_DEFENSELESS,
	EXECUTE,
	
	PROTECTED,
	PROTECT_ALLY,
	
	# no param.
	COMBAT_FOCUSED,
	COMBAT_ENTER,
	SHOP_ENTER,
	LEVEL_UP,
	
	TURN_START,
	TURN_END,
	ALLY_ACTED,
	
	AIMED,
	HIT,
	DODGE,
	TURN_PASS,
	TAKE_FRIENDLY_SKILL,
	ENTER_EXHAUST,
	ENTER_DEFENSELESS,
	ENTER_LUCID,
	ENTER_HAZY,
	ENTER_FAINT,
	EXIT_LUCID,
	EXIT_HAZY,
	EXIT_FAINT,
	DEATH,
	ALLY_DEATH,
	
	COMBAT_END,
}

enum IndicateType
{
	# effect.
	DMG,
	ENERGY_DMG,
	HEAL,
	GAIN_ENERGY,
	SHIELD,
	
	# bool values.
	CRIT,
	DODGE,
	SHIELD_BRAKE,
}

enum ExistState
{
	LUCID,
	HAZY,
	FAINT
}

enum Stance
{
	COMMON,
	COUNTER,
	ASSIST
}

# sometimes used at skill ratio.
enum Stat
{
	### necessary stats.
	LEVEL = 0,
	POWER,
	
	### main stats.
	MAX_HEALTH,
	MAX_ENERGY,
	STRENGTH,
	INTELLIGENCE,
	DEXTERITY,
	FAITH,
	CRIT,
	CRIT_MUL,
	ARMOR,
	DODGE,
	ARMOR_PEN,
	ARMOR_PEN_RATE,
	
	### sub and implicit stats, that initialized with value or 0.
	# about sub act.
	COUNTER_CHANCE,
	ASSIST_CHANCE,
	COUNTER_DMG_AMP,
	ASSIST_DMG_AMP,
	
	# new type stat.
	RESILIENCE,
	ADD_ENERGY_REG,
	
	# many type amps.
	IMPACT_AMP,
	SLASH_AMP,
	PIERCE_AMP,
	NATURE_AMP,
	ARCANE_AMP,
	MYSTIC_AMP,
	ENERGY_DMG_AMP,
	TAKE_DMG_AMP,
	GAIN_EXP_AMP,
	
	### not initialized values. boolean.
	# boolean stat.
	IGNORE_EXHAUST_DEBUFF,
	
}

# NOTE: stats that character-specific, must displayed, and can't increase by equipment.
enum SpecialStat
{
	STARSHARD, # for astrologist.
}

# not indivisual, it affects at party.
enum PartyStat
{
	# has amount.
	GAIN_GOLD_AMP,
	SHOP_DISCOUNT,
	
	# not have amount, so true and false key.
	IGNORE_NEGATIVE_ENCOUNTER_EFFECT,
}

# for enemies.
enum Mutation
{
	CRIT_RESIST_10,
	DODGE_IGNORE_10,
	DMG_AMP_10,
	ENERGY_DMG_AMP_10,
	SHIELD_DMG_AMP_20,
	VIGOR_5, # restore per turn.
	TAKE_DMG_REDUCE_ABSOLUTE_10,
	TAKE_DMG_REDUCE_PERCENT_5,
	
	MARK_IMMUNE,
	EXHAUST_DEBUFF_IMMUNE,
}

enum Attribute
{
	IMPACT,
	SLASH,
	PIERCE,
	NATURE,
	ARCANE,
	MYSTIC
}

enum Status
{
	BREAK,
	DEFENSELESS,
	RIFT,
	MEND,
	EXHAUST,
	OVERBREATHING,
	MARKED,
	STEALTH,
}
