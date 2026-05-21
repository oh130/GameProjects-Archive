class_name PaintCall extends Button

@onready var ink: HBoxContainer = %Ink
@onready var ink_cost: Label = %InkCost

var paint_cost := 40

func _ready():
	ink_cost.text = str(paint_cost)

func check_callable():
	if not is_node_ready():
		await ready
	
	disabled = int(GameManager.ground.ink) < paint_cost
