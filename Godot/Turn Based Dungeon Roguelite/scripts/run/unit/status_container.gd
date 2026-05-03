class_name StatusContainer extends Control

const STATUS_UI_SCENE := preload("res://scenes/run/unit/status_ui.tscn")

var status_uis : Array[StatusUI]
var status_tooltip_strings : Array[String]

func _ready():
	status_tooltip_strings.resize(Enum.Status.size())
	for i in Enum.Status.size():
		var ui := STATUS_UI_SCENE.instantiate()
		add_child(ui)
		status_uis.append(ui)
		
		ui.get_child(0).texture = SubInfoLayer.status_icons[i]
		ui.get_child(1).text = Enum.Status.keys()[i]
		ui.mouse_entered.connect(on_status_ui_mouse_entered.bind(i))
		ui.mouse_exited.connect(on_status_ui_mouse_exited)

func set_statuses(status_arr : Array[int]):
	for i in status_arr.size():
		status_uis[i].count = status_arr[i]
		match i:
			Enum.Status.BREAK:
				status_tooltip_strings[i] = "%s %+d" % [tr("DMG_TAKEN"), status_arr[i] * 10]
			Enum.Status.EXHAUST:
				status_tooltip_strings[i] = "%s %+d" % [tr("DMG"), - status_arr[i] * 10]
			Enum.Status.OVERBREATHING:
				status_tooltip_strings[i] = "%s %+d" % [tr("DODGE"), - status_arr[i] * 20]

func on_status_ui_mouse_entered(i : int):
	SubInfoLayer.show_status_tooltip(tr(Enum.Status.keys()[i]), status_tooltip_strings[i], get_global_mouse_position())

func on_status_ui_mouse_exited():
	SubInfoLayer.hide_status_tooltip()
