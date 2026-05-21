class_name ElemSample extends Control

enum State { VIEW, REWARD, ERASE }

@onready var grade_label: Label = %GradeLabel
@onready var property_ui: GridContainer = %PropertyUI

@export var state : State

var data : ElementData : set = set_data

func set_data(elem_data : ElementData):
	data = elem_data
	
	if not is_node_ready():
		await ready
	
	grade_label.text = str(data.grade)
	
	for prop in property_ui.get_children():
		property_ui.remove_child(prop)
	
	for prop in data.properties:
		var inst := Element.PROPERTY_UI_SCENE.instantiate()
		property_ui.add_child(inst)
		inst.init_property_ui(prop, data.properties[prop])

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		match state:
			State.REWARD:
				adding_elem()
			State.ERASE:
				GameManager.data_manager.remove_element_from_deck(data)

func adding_elem():
	EventBus.hide_reward.emit()
	
	if data.is_instant:
		GameManager.board.prefare_instant_element(data)
	else:
		GameManager.data_manager.add_element_to_deck(data)
		EventBus.reward_selected.emit()
