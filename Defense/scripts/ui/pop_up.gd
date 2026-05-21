class_name PopUp extends CanvasLayer

@onready var description = %Description
@onready var confirm = %Confirm

func set_popup(des : String, conf_c : Callable):
	if not is_node_ready():
		await ready
	
	description.text = des
	confirm.pressed.connect(conf_c)
