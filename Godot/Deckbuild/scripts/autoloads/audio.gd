extends Node

@onready var bgm = %BGM
@onready var sfxs = %SFXs.get_children()

func play_bgm(audio : AudioStream):
	bgm.stop()
	bgm.stream = audio
	bgm.play()

func stop_bgm():
	bgm.stop()

func play_sfx(audio : AudioStream, solo := false):
	if solo:
		stop_all_sfx()
	
	for sfx : AudioStreamPlayer in sfxs:
		if not sfx.playing:
			sfx.stream = audio
			sfx.play()
			break

func stop_all_sfx():
	for sfx : AudioStreamPlayer in sfxs:
		sfx.stop()
