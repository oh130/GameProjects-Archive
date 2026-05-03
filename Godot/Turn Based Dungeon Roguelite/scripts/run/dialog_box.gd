class_name DialogBox extends Control

@onready var label: Label = %Label
@onready var timer: Timer = %Timer

func _ready():
	timer.timeout.connect(hide)
	hide()

func set_dialog(dialog : String):
	dialog = tr(dialog)
	label.text = dialog
	label.visible_characters = 0
	show()
	
	timer.start()
	var tween := create_tween()
	tween.tween_property(label, "visible_characters", dialog.length(), 0.05 * dialog.length())
