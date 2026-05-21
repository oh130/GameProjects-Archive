class_name EnhancementUI extends TextureRect

var data : Enhancement : set = set_data

signal enhancement_clicked(enh : Enhancement)

func _ready():
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_data(enh : Enhancement):
	data = enh
	
	texture = data.icon

func _on_gui_input(event : InputEvent):
	if event.is_action_pressed("left_mouse"):
		enhancement_clicked.emit(data)

func _on_mouse_entered():
	SubInfoLayer.show_enhancement_tooltip(self)

func _on_mouse_exited():
	SubInfoLayer.hide_enhancement_tooltip()
