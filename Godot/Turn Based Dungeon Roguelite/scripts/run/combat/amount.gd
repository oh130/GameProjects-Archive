class_name Amount extends Resource

@export var amount : float
@export var ratios : Dictionary[Enum.Stat, float]

func _init():
	amount = 0.0

func apply_ratios(caster_stats : Dictionary[Enum.Stat, int]) -> int:
	var total := amount
	for key in ratios:
		total += caster_stats[key] * ratios[key]
	
	return roundi(total)

func add(val : Amount):
	amount += val.amount
	
	for ratio in val.ratios:
		if ratios.has(ratio):
			ratios[ratio] += val.ratios[ratio]
		else:
			ratios[ratio] = val.ratios[ratio]

func check_zero() -> bool:
	var flag := true
	
	if roundi(amount) != 0:
		flag = false
	
	for key in ratios:
		if not is_equal_approx(ratios[key], 0):
			flag = false
	
	return flag
