extends Control

@onready var settings = %Settings
@onready var continue_button = %ContinueButton

@export var bgm : AudioStream

func _ready():
	continue_button.visible = SaveData.check_data()
	
	Audio.play_bgm(bgm)

func _on_continue_button_pressed():
	SceneManager.change_scene(SceneManager.GameScene.RUN)

func _on_new_game_button_pressed():
	if SaveData.check_data():
		SubInfoLayer.make_popup("You will lose your current run.\nok?", start_new_game)
	else:
		start_new_game()

func _on_setting_button_pressed():
	settings.show()

func _on_credit_button_pressed():
	pass # Replace with function body.

func _on_exit_button_pressed():
	get_tree().quit()

func start_new_game():
	SaveData.delete_data()
	SceneManager.change_scene(SceneManager.GameScene.RUN)
