extends Label

func show_info(obj : Node, additional_type : int):
	text = str(obj) + " " + str(additional_type)

func hide_info():
	text = "None"
