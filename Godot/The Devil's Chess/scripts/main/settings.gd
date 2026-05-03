extends Node

@onready var display_mode = $SettingMenu/HBox/Values/DisplayMode
@onready var bgm = $SettingMenu/HBox/Values/BGM
@onready var sfx = $SettingMenu/HBox/Values/SFX

const setting_path = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	DisplayServer.window_set_min_size(Vector2i(1280,720))
	
	config.set_value("Display", "Mode", 2)
	config.set_value("Audio", "BGM", 1.0)
	config.set_value("Audio", "SFX", 1.0)
	
	_load()

func _save():
	config.save(setting_path)

func _load():
	if config.load(setting_path) != OK:
		_save()
		return
	
	load_audio_setting()
	load_display_setting()

func load_audio_setting():
	bgm.value = config.get_value("Audio", "BGM")
	sfx.value = config.get_value("Audio", "SFX")

func load_display_setting():
	display_mode.select(config.get_value("Display", "Mode"))

func _on_bgm_value_changed(value : float):
	set_volume(1, value)

func _on_sfx_value_changed(value : float):
	set_volume(2, value)

func _on_display_mode_item_selected(idx : int):
	config.set_value("Display", "Mode", idx)
	_save()
	
	match idx:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1280,720))
			DisplayServer.window_set_position(0.25 * DisplayServer.screen_get_size())

func set_volume(idx : int, value : float):
	match idx:
		1:
			config.set_value("Audio", "BGM", value)
		2:
			config.set_value("Audio", "SFX", value)
	
	AudioServer.set_bus_volume_db(idx, linear_to_db(value))
	_save()
