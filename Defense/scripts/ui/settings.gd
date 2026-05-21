extends CanvasLayer

const SETTING_PATH := "user://settings.cfg"
var config := ConfigFile.new()

const translation_arr := ["en", "kr"]

@onready var language = %Language
@onready var display_mode = %DisplayMode
@onready var bgm = %BGM
@onready var sfx = %SFX

func _ready():
	config.set_value("Audio", "BGM", 1)
	config.set_value("Audio", "SFX", 1)
	config.set_value("Display", "Mode", 2)
	config.set_value("Language", "Locale", 0)
	_load()

func _save():
	config.save(SETTING_PATH)

func _load():
	if config.load(SETTING_PATH) != OK:
		_save()
		return
	
	load_audio_setting()
	load_display_setting()
	load_language_setting()

func load_audio_setting():
	bgm.value = config.get_value("Audio", "BGM")
	sfx.value = config.get_value("Audio", "SFX")

func load_display_setting():
	var cur_mode : int = config.get_value("Display", "Mode")
	display_mode.select(cur_mode)
	_on_display_mode_item_selected(cur_mode)

func load_language_setting():
	var cur_loc : int = config.get_value("Language", "Locale")
	language.select(cur_loc)
	TranslationServer.set_locale(translation_arr[cur_loc])

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

func _on_language_item_selected(idx : int):
	config.set_value("Language", "Locale", idx)
	_save()
	
	TranslationServer.set_locale(translation_arr[idx])
	SubInfoLayer.make_popup("EXIT?", get_tree().quit)

func set_volume(idx : int, value : float):
	match idx:
		1:
			config.set_value("Audio", "BGM", value)
		2:
			config.set_value("Audio", "SFX", value)
	
	AudioServer.set_bus_volume_db(idx, linear_to_db(value))
	_save()

func _on_back_pressed():
	hide()
