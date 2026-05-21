extends CanvasLayer

@onready var main = $".."

func _on_start_pressed():
	await Global.fade_out()
	main.inactive_main_menu()
	main.active_level_manager()
	Global.fade_in()

func _on_settings_pressed():
	main.open_setting()

func _on_level_editor_pressed():
	await Global.fade_out()
	main.inactive_main_menu()
	main.active_level_editor()
	Global.fade_in()

func _on_credit_pressed():
	pass # Replace with function body.

func _on_exit_pressed():
	get_tree().quit()
