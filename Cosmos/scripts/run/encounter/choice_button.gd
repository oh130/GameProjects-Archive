class_name ChoiceButton extends Button

@onready var rich_text_label: RichTextLabel = %RichTextLabel

var choice : Choice : set = set_choice

func set_choice(val : Choice):
	choice = val
	
	rich_text_label.text = choice.description
