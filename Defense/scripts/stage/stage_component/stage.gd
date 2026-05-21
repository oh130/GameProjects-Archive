class_name Stage extends Node2D

@onready var ground: Ground = %Ground

@onready var projectiles: Node2D = %Projectiles
@onready var effects: Node2D = %Effects

@onready var gui: CanvasLayer = $GUI

@onready var stage_clear: ColorRect = %StageClear
@onready var stage_fail: ColorRect = %StageFail

@onready var game_timer: Timer = %GameTimer

signal stage_start()

func _ready():
	GameManager.stage = self
	GameManager.stage_finished = false
	GameManager.set_ui_focus_mode()
	
	AttackManager.initialize()
	
	stage_start.emit()

func stage_cleared():
	if GameManager.stage_data.stage_index == GameManager.game_progress:
		GameManager.game_progress += 1
	
	GameManager.paper += calculate_paper_reward()
	GameManager.save_game()
	
	GameManager.stage_finished = true
	stage_clear.show()

func stage_failed():
	GameManager.stage_finished = true
	stage_fail.show()

func calculate_paper_reward() -> int:
	return GameManager.stage_data.base_paper_reward

func restart_stage():
	SceneManager.change_scene(SceneManager.GameScene.STAGE)
