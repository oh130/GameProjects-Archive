class_name ChapterButton extends Button

var chapter : Chapter : set = set_chapter

func set_chapter(chap : Chapter):
	chapter = chap
	
	text = chap.resource_name
