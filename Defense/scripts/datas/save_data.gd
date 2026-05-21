class_name SaveData extends Resource

const SAVE_PATH := "user://savegame.tres"

# datas.
@export var paper : int
@export var game_progress : int
@export var purchased_items : Array[ItemData]

func save_data():
	ResourceSaver.save(self, SAVE_PATH)

static func check_data() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func load_data() -> SaveData:
	if FileAccess.file_exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	
	var data := SaveData.new()
	data.save_data()
	return data

static func delete_data():
	if check_data():
		DirAccess.remove_absolute(SAVE_PATH)
