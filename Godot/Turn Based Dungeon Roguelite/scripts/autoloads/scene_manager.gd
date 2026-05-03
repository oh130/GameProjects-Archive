extends CanvasLayer

enum GameScene { MAIN_MENU, TAVERN, RUN }

const MAIN_MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")
const TAVERN_SCENE := preload("res://scenes/tavern/tavern.tscn")
const RUN_SCENE := preload("res://scenes/run/run.tscn")

@onready var screen = %Screen
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var scene : PackedScene

func _ready():
	screen.hide()

func change_scene(game_scene : GameScene):
	match game_scene:
		GameScene.MAIN_MENU:
			scene = MAIN_MENU_SCENE
		GameScene.TAVERN:
			scene = TAVERN_SCENE
		GameScene.RUN:
			scene = RUN_SCENE
	
	GameManager.deny_input = true
	Audio.fade_bgm(1)
	animation_player.play("fade_out")

func fade_out_finished():
	get_tree().change_scene_to_packed(scene)
	animation_player.play("fade_in")

func fade_in_finished():
	GameManager.set_ui_focus_mode()
	GameManager.deny_input = false
