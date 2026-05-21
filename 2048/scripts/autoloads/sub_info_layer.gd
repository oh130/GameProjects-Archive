extends CanvasLayer

const POP_UP_SCENE := preload("res://scenes/ui/pop_up.tscn")
const INDICATOR_SCENE := preload("res://scenes/run/indicator.tscn")

const POS_MOD := Vector2(100, 0)

@onready var tooltip_box = %TooltipBox
@onready var id_label = %IdLabel
@onready var desc_label = %DescLabel

func _ready():
	tooltip_box.hide()

func show_tooltip_box(data_id : String, data_desc : String, master_pos : Vector2):
	id_label.text = data_id
	desc_label.text = data_desc
	tooltip_box.position = master_pos + POS_MOD
	tooltip_box.show()

func hide_tooltip_box():
	tooltip_box.hide()

func make_indicator(amount : int, type : Indicator.Type, pos : Vector2):
	var indicator := INDICATOR_SCENE.instantiate()
	indicator.init_indicator(amount, type, pos)
	add_child(indicator)

func make_popup(des : String, conf_c : Callable):
	var pop_up := POP_UP_SCENE.instantiate()
	pop_up.set_popup(des, conf_c)
	add_child(pop_up)
