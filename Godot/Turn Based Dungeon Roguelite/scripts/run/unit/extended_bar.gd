class_name ExtendedBar extends ProgressBar

@onready var sub_bar: ProgressBar = %SubBar
@onready var label: Label = %Label
@onready var shield: ProgressBar = %Shield

var style : StyleBoxFlat
var tween : Tween

func _ready():
	value = 100
	sub_bar.value = 100
	style = StyleBoxFlat.new()

func set_val_with_max(val : int, max_val: int, immidiately := false):
	var cur_val := 100 * float(val) / max_val
	label.text = "%d / %d" % [val, max_val]
	
	if immidiately:
		value = cur_val
		sub_bar.value = cur_val
	else:
		set_cur_value(cur_val)

func set_cur_value(val : float):
	var prev := value
	
	if prev == val:
		return
	elif prev > val:
		# damaged.
		style.bg_color = Color.ORANGE
		sub_bar.add_theme_stylebox_override("fill", style)
		value = val
		
		tween = create_tween()
		tween.tween_property(sub_bar, "value", val, 1)
	else:
		# restored.
		style.bg_color = Color.GREEN
		sub_bar.add_theme_stylebox_override("fill", style)
		sub_bar.value = val
		
		tween = create_tween()
		tween.tween_property(self, "value", val, 1)

func set_shield(val : bool):
	shield.visible = val
