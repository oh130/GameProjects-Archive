class_name ProfileSkillUI extends SkillUI

@onready var selected_texture: ColorRect = %SelectedTexture

var player_data : PlayerData : set = set_player_data
var selected := false : set = set_selected

func _ready() -> void:
	super._ready()
	pressed.connect(_on_pressed)
	selected_texture.hide()

func set_player_data(pd : PlayerData):
	player_data = pd

func set_selected(value : bool):
	selected = value
	
	if value:
		selected_texture.show()
	else:
		selected_texture.hide()

func _on_pressed() -> void:
	if SituationManager.on_combat:
		return
	
	if player_data.selected_skills.has(data):
		player_data.selected_skills.erase(data)
		Audio.play_sfx(Audio.skill_select_sfx)
		selected = false
	else:
		if player_data.selected_skills.size() < PlayerData.MAXIMUM_SELECTED_SKILLS:
			player_data.selected_skills.append(data)
			Audio.play_sfx(Audio.skill_select_sfx)
			selected = true
