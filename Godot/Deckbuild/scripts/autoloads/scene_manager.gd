extends CanvasLayer

enum GameScene { MAIN_MENU, RUN }

const MAIN_MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")
const RUN_SCENE := preload("res://scenes/run/run.tscn")

@onready var screen = %Screen

func _ready():
	screen.hide()

func change_scene(game_scene : GameScene):
	await fade_out()
	
	var scene : PackedScene
	match game_scene:
		GameScene.MAIN_MENU:
			scene = MAIN_MENU_SCENE
		GameScene.RUN:
			scene = RUN_SCENE
	
	get_tree().change_scene_to_packed(scene)
	
	await fade_in()

func fade_in():
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(screen, "modulate:a", 0, 0.2)
	await tween.finished
	screen.hide()
	GameManager.deny_input = false

func fade_out():
	GameManager.deny_input = true
	screen.show()
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(screen, "modulate:a", 1, 0.2)
	await tween.finished
