class_name ProfileWindowContainer extends Control

@onready var profiles: Control = %Profiles
@onready var player_buttons: Control = %PlayerButtons

var profile_arr : Array[ProfileWindow]

func _ready():
	profiles.hide()
	
	for child in player_buttons.get_children():
		child.hide()

func init_profile():
	var i := 0
	for player_data in DataManager.player_datas:
		var pw : ProfileWindow = profiles.get_child(i)
		var button : Button = player_buttons.get_child(i)
		pw.data = player_data
		profile_arr.append(pw)
		button.pressed.connect(open_profile.bind(i))
		button.show()
		i += 1
	
	profiles.get_child(0).show()

func open_profile(idx : int):
	for pw in profile_arr:
		pw.hide()
	profile_arr[idx].show()

func update_profiles():
	for pw in profile_arr:
		pw.update_profile()

func _on_handle_button_toggled(toggled_on: bool) -> void:
	profiles.visible = toggled_on
