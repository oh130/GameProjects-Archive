class_name SkillUI extends Button

@onready var skill_icon: TextureRect = %SkillIcon
@onready var enhanced_texture: ColorRect = %EnhancedTexture

var data : PlayerSkill : set = set_data

func _ready():
	enhanced_texture.hide()
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_data(skill : PlayerSkill):
	data = skill
	
	skill_icon.texture = data.icon

func set_enhanced_texture():
	if data.enhancement:
		enhanced_texture.visible = data.enhancement.selected

func _on_mouse_entered() -> void:
	SubInfoLayer.show_skill_tooltip(data, global_position)

func _on_mouse_exited() -> void:
	SubInfoLayer.hide_skill_tooltip()
