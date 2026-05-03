class_name SkillFactor extends Resource

var crit_occured := false
var weakness_attacked := false
var defenseless_entered := false
var target_died := false

func overwrite(factor : SkillFactor):
	crit_occured = (crit_occured or factor.crit_occured)
	weakness_attacked = (weakness_attacked or factor.weakness_attacked)
	defenseless_entered = (defenseless_entered or factor.defenseless_entered)
	target_died = (target_died or factor.target_died)
