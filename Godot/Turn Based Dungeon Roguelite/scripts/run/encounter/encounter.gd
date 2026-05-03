class_name Encounter extends CanvasLayer

const CHOICE_BUTTON_SCENE := preload("res://scenes/run/encounter/choice_button.tscn")

@onready var encounter_box: VBoxContainer = %EncounterBox
@onready var encounter_id: RichTextLabel = %EncounterID
@onready var encounter_structure: TextureButton = %EncounterStructure
@onready var choices: VBoxContainer = %Choices

var data : EncounterData : set = set_encounter

func _ready():
	encounter_structure.pressed.connect(
		func():
			encounter_structure.disabled = true
			encounter_box.show()
	)
	
	encounter_box.hide()
	hide()

func enter_encounter():
	var rand_encounter_data : EncounterData = Random.pick_random(Pool.encounter_pool)
	while DataManager.save_data.visited_encounters.has(data)\
	or not (rand_encounter_data.appear_chapter == ""\
	or rand_encounter_data.appear_chapter == DataManager.save_data.chapter.resource_name):
		rand_encounter_data = Random.pick_random(Pool.encounter_pool)
	
	data = rand_encounter_data
	DataManager.save_data.visited_encounters.append(rand_encounter_data)
	
	# temp.
	if Pool.encounter_pool.size() == DataManager.save_data.visited_encounters.size():
		DataManager.save_data.visited_encounters.clear()
	
	for p in DataManager.run.players:
		SituationManager.occur(Enum.Situation.ENCOUNTER_ENTER, p, data)
	
	encounter_structure.disabled = false
	show()

func set_encounter(encounter_data : EncounterData):
	#encounter_desc.visible_characters = 0
	#var tween := create_tween()
	#tween.tween_property(encounter_desc, "visible_characters", encounter_data.description.length(), 2)
	#await tween.finished
	
	data = encounter_data
	encounter_id.text = data.resource_name
	encounter_structure.texture_normal = data.structure_texture
	
	for child in choices.get_children():
		choices.remove_child(child)
	
	for choice in data.choices:
		var specific_flag := false
		if choice.player_specific != "":
			for p in DataManager.player_datas:
				if choice.player_specific == p.resource_name:
					specific_flag = true
					break
		else:
			specific_flag = true
		
		if not specific_flag:
			continue
		
		var inst := CHOICE_BUTTON_SCENE.instantiate()
		choices.add_child(inst)
		inst.choice = choice
		inst.disabled = !choice.check_condition()
		inst.pressed.connect(choose.bind(choice))

func focused_player_changed():
	if not encounter_box.visible:
		return
	
	for choice_button : ChoiceButton in choices.get_children():
		choice_button.disabled = !choice_button.choice.check_condition()

func choose(choice : Choice):
	choice.outcome()
	encounter_box.hide()
	
	# after TODO: if equipment outcome, then show equipment, and show route choice next.
	DataManager.run.show_route_choice()
