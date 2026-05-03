class_name SaveData extends Resource

const SAVE_PATH := "user://savegame.tres"

# about random.
@export var game_seed : int
@export var state : int
@export var combat_seed : int
@export var combat_state : int

# about current.
@export var chapter : Chapter
@export var current_route : Enum.Route
@export var since_last_elite_visit : int
@export var gold : int

# about progress.
@export var progress : int
@export var difficulty : int
@export var cleared_chapters : Array[String]
@export var cleared_routes : Array[Enum.Route]

# about players.
@export var player_datas : Array[PlayerData]
@export var party_stats : Dictionary[Enum.PartyStat, int]
@export var consumables : Dictionary[Consumable, int]

# handle event.
@export var visited_encounters : Array[EncounterData]
@export var current_enemy_group_pool : Array[EnemyGroup]
@export var current_elite_group_pool : Array[EnemyGroup]

func save_data():
	ResourceSaver.save(self, SAVE_PATH)

static func check_data() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func load_data() -> SaveData:
	if check_data():
		return ResourceLoader.load(SAVE_PATH, "SaveData", ResourceLoader.CACHE_MODE_IGNORE)
	
	return null

static func delete_data():
	if check_data():
		DirAccess.remove_absolute(SAVE_PATH)
