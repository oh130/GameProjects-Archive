extends Node

const BASIC_VOLUME := 10.0

@onready var bgm: AudioStreamPlayer = %BGM
@onready var sfxs: Array[Node] = %SFXs.get_children()

@export_group("SFXs")
@export var combat_encounter : AudioStream
@export var player_turn : AudioStream
@export var enemy_turn : AudioStream
@export var turn_pass : AudioStream
@export var win : AudioStream
@export var defeat : AudioStream

@export var unit_focusing : AudioStream
@export var buy_sell : AudioStream
@export var equip : AudioStream
@export var consume : AudioStream

@export var skill_select_sfx : AudioStream

func _ready():
	for sfx : AudioStreamPlayer in sfxs:
		sfx.volume_db = BASIC_VOLUME

func play_bgm(audio : AudioStream):
	bgm.volume_db = BASIC_VOLUME
	bgm.stop()
	bgm.stream = audio

	bgm.play()

func fade_bgm(time : float):
	var tween := create_tween()
	tween.tween_property(bgm, "volume_db", 0, time)
	await tween.finished

func stop_bgm():
	bgm.stop()

func play_sfx(audio : AudioStream, solo := false):
	if not audio:
		return
	
	if solo:
		stop_all_sfx()
	
	var target_sfx : AudioStreamPlayer
	for sfx : AudioStreamPlayer in sfxs:
		if sfx.stream == audio or not sfx.playing:
			target_sfx = sfx
			break
	
	if not target_sfx:
		return
	
	target_sfx.stream = audio
	target_sfx.play()
	await target_sfx.finished

func stop_all_sfx():
	for sfx : AudioStreamPlayer in sfxs:
		sfx.stop()
