extends ProgressBar

func _ready():
	GlobalData.connect("player_hp_changed",on_hp_changed)

func on_hp_changed(hp : int):
	value = hp
