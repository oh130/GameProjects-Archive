extends CanvasLayer

func _ready():
	hide()

func _input(event : InputEvent):
	if event is InputEventKey and event.is_action_pressed("pause"):
		if visible:
			unpause()
		else:
			pause()
		
		get_viewport().set_input_as_handled()

func pause():
	show()
	get_tree().paused = true

func unpause():
	hide()
	get_tree().paused = false

func _on_resume_pressed():
	unpause()

func _on_exit_pressed():
	exit_to_main_menu()
	#SubInfoLayer.make_popup("EXIT_TO_MM?", exit_to_main_menu)

func exit_to_main_menu():
	unpause()
	SituationManager.on_combat = false
	SituationManager.on_enemy_turn = false
	SituationManager.on_skill_anim = false
	SituationManager.usual_state = false
	SceneManager.change_scene(SceneManager.GameScene.MAIN_MENU)
