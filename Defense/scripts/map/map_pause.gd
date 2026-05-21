extends CanvasLayer

func _ready():
	hide()

func _input(event : InputEvent):
	if not GameManager.deny_input and event.is_action_pressed("ui_cancel"):
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
	SubInfoLayer.make_popup("EXIT_TO_MAIN_MENU?", exit_to_main_menu)

func exit_to_main_menu():
	hide()
	SceneManager.change_scene(SceneManager.GameScene.MAIN_MENU)
