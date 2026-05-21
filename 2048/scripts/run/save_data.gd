class_name SaveData extends Resource

const SAVE_PATH := "user://savegame.tres"

@export var game_seed : int
@export var state : int

@export var progress : int
@export var game_time : int

@export var max_health : int
@export var health : int
@export var board_state : Array[Array]
@export var deck : Array[ElementData]
@export var items : Array[ItemData]

func save_data():
	ResourceSaver.save(self, SAVE_PATH)

static func check_data() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func load_data() -> SaveData:
	if FileAccess.file_exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	
	return null

static func delete_data():
	if check_data():
		DirAccess.remove_absolute(SAVE_PATH)
