class_name DeckView extends Control

const ELEM_SAMPLE_SCENE := preload("res://scenes/run/elem_sample.tscn")

@onready var elements: GridContainer = %Elements

func _ready():
	hide()

func open_deck_view(state : ElemSample.State):
	for data in GameManager.data_manager.deck:
		var elem_sample := ELEM_SAMPLE_SCENE.instantiate()
		elem_sample.state = state
		elem_sample.data = data
		elements.add_child(elem_sample)
	
	show()

func close_deck_view():
	for elem in elements.get_children():
		elem.queue_free()
	
	hide()

func deck_button_pressed():
	if visible:
		close_deck_view()
	else:
		open_deck_view(ElemSample.State.VIEW)
