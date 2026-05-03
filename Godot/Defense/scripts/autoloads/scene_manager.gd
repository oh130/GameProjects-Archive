extends CanvasLayer

enum GameScene { MAIN_MENU, MAP, OPERATION, STAGE }

const MAIN_MENU_SCENE := preload("res://scenes/main_menu.tscn")
const MAP_SCENE := preload("res://scenes/map/map.tscn")
const OPERATION_SCENE := preload("res://scenes/operation/operation.tscn")
const STAGE_SCENE := preload("res://scenes/stage/stage.tscn")

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite_2d: Sprite2D = %Sprite2D

var change_target_scene : GameScene

func _ready():
	sprite_2d.hide()

func change_scene(game_scene : GameScene):
	change_target_scene = game_scene
	
	GameManager.deny_input = true
	SubInfoLayer.delete_all_popup()
	sprite_2d.show()
	animation_player.play("fade_out")

func fade_out_ended():
	if get_tree().paused:
		get_tree().paused = false
	
	var scene : PackedScene
	match change_target_scene:
		GameScene.MAIN_MENU:
			scene = MAIN_MENU_SCENE
		GameScene.MAP:
			scene = MAP_SCENE
		GameScene.OPERATION:
			scene = OPERATION_SCENE
		GameScene.STAGE:
			scene = STAGE_SCENE
	
	get_tree().change_scene_to_packed(scene)
	
	animation_player.play("fade_in")

func fade_in_ended():
	sprite_2d.hide()
	GameManager.deny_input = false

#func fade_in():
	#var tween : Tween = get_tree().create_tween()
	#tween.tween_property(screen, "modulate:a", 0, 0.2)
	#await tween.finished
	#screen.hide()
	#GameManager.deny_input = false
#
#func fade_out():
	#GameManager.deny_input = true
	#screen.show()
	#var tween : Tween = get_tree().create_tween()
	#tween.tween_property(screen, "modulate:a", 1, 0.2)
	#await tween.finished
