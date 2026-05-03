class_name Indicator extends Control

enum Type
{
	HEALTH_POSITIVE,
	HEALTH_NEGATIVE,
	ARMOR_POSITIVE,
	ARMOR_NEGATIVE
}

@onready var text = %Text

var tween : Tween

func init_indicator(amount : int, type : Type, pos : Vector2):
	if not is_node_ready():
		await ready
	
	match type:
		Type.HEALTH_POSITIVE:
			modulate = Color.GREEN
		Type.HEALTH_NEGATIVE:
			modulate = Color.RED
		Type.ARMOR_POSITIVE:
			modulate = Color.DIM_GRAY
		Type.ARMOR_NEGATIVE:
			modulate = Color.DARK_CYAN
	
	position = pos
	text.text = str(amount)
	indicator_animation()

func indicator_animation():
	tween = create_tween()
	tween.tween_property(self, "position", position + 50 * Vector2.UP, 0.5)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
