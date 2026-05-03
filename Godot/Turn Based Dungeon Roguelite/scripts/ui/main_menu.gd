extends Control

@onready var settings: CanvasLayer = %Settings
@onready var continue_button: CustomButton = %ContinueButton
@onready var new_game_button: CustomButton = %NewGameButton
@onready var settings_button: CustomButton = %SettingsButton
@onready var credit_button: CustomButton = %CreditButton
@onready var exit_button: CustomButton = %ExitButton

@export var main_bgm : AudioStream

func _ready():
	settings.hide()
	
	continue_button.pressed.connect(_on_continue_button_pressed)
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	settings_button.pressed.connect(_on_setting_button_pressed)
	credit_button.pressed.connect(_on_credit_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	continue_button.visible = SaveData.check_data()
	
	Audio.play_bgm(main_bgm)

func _on_continue_button_pressed():
	SceneManager.change_scene(SceneManager.GameScene.RUN)

func _on_new_game_button_pressed():
	if SaveData.check_data():
		start_new_game()
		#SubInfoLayer.make_popup("You will lose your current run.\nok?", start_new_game)
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
	SceneManager.change_scene(SceneManager.GameScene.TAVERN)
