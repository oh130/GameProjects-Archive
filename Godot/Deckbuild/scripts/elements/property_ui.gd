class_name PropertyUI extends TextureRect

@onready var amount_label: Label = %AmountLabel

var property : Property
var amount : int : set = set_amount

func set_amount(value : int):
	amount = clampi(value, 0, 999)
	amount_label.text = str(amount)

func init_property_ui(p : Property, a : int):
	property = p
	amount = a
	
	texture = property.icon
	
	if property.stackable:
		amount_label.show()
	else:
		amount_label.hide()
	
