extends Node

# first index : chapter
# second index : level
# e.g. level_info[chapter][level]["enemies"]

const json_route = "res://resources/data/level_info.json"

var level_info : Dictionary

func _ready():
	read_level_info_file()
	
func read_level_info_file():
	var file = FileAccess.open(json_route, FileAccess.READ)
	level_info = JSON.parse_string(file.get_as_text())
	file.close()

func write_level_info_file():
	var file = FileAccess.open(json_route, FileAccess.WRITE)
	file.store_string(JSON.stringify(level_info, "\t"))
	file.close()
