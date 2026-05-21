extends Node

# run state booleans.
var deny_input := false

# set up datas.
var stage_data : StageData
var picked_items : Array[ItemData]

# in stage.
var stage : Stage
var ground : Ground
var stage_finished : bool

# save.
var save_data : SaveData

# save datas.
var paper := 0
var game_progress := 0
var purchased_items : Array[ItemData]

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#save_game()
		get_tree().quit()

func save_game():
	save_data.paper = paper
	save_data.game_progress = game_progress
	save_data.purchased_items = purchased_items
	
	save_data.save_data()

func load_game():
	save_data = SaveData.load_data()
	
	paper = save_data.paper
	game_progress = save_data.game_progress
	purchased_items = save_data.purchased_items

func set_ui_focus_mode():
	recursive(get_tree().root)

func recursive(node : Node):
	if node is Control:
		node.focus_mode = Control.FOCUS_NONE

	for child in node.get_children():
		recursive(child)

func shake(thing: Control, strength: float = 20, duration: float = 0.1):
	if not thing:
		return

	var orig_pos := thing.position
	var shake_count := 10
	var tween := create_tween()
	
	for i in shake_count:
		var shake_offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
		var target := orig_pos + strength * shake_offset
		if i % 2 == 0: 
			target = orig_pos
		tween.tween_property(thing, "position", target, duration / float(shake_count))
		strength *= 0.75
	
	tween.finished.connect(func(): thing.position = orig_pos)
