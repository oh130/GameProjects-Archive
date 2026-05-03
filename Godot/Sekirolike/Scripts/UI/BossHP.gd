extends ProgressBar

func _ready():
	GlobalData.connect("boss_hp_changed",on_boss_hp_changed)

func on_boss_hp_changed(hp : int):
	value = hp
