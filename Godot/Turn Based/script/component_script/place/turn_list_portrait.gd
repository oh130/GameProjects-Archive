extends TextureRect

@export var portrait_unit : StatusController

func portrait_create(unit : StatusController):
	portrait_unit = unit
	texture = GlobalData.portraits[unit.unit_name]
