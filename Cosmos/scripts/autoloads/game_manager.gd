extends Node

# run state booleans.
var deny_input := false

func _ready() -> void:
	set_ui_focus_mode()

func set_ui_focus_mode():
	recursive(get_tree().root)

func recursive(node : Node):
	if node is Control:
		node.focus_mode = Control.FOCUS_NONE

	for child in node.get_children():
		recursive(child)

func hide_tween(node : Control, time := 0.2):
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 0, time)
	await tween.finished
	node.hide()

func show_tween(node : Control, time := 0.2):
	node.modulate.a = 0
	node.show()
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 1, time)
	await tween.finished

func smooth_move(node : Control, end_pos : Vector2, time := 0.5):
	var tween : Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "position", end_pos, time)
	await tween.finished

func shake(node: Node, orig_pos : Vector2, strength: float = 10, duration: float = 0.4):
	if not node:
		return
	
	var shake_count := 10
	var tween := create_tween()
	
	for i in shake_count:
		var shake_offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
		var target := orig_pos + strength * shake_offset
		if i % 2 == 0: 
			target = orig_pos
		tween.tween_property(node, "position", target, duration / float(shake_count))
		strength *= 0.75
	
	tween.finished.connect(func(): node.position = orig_pos)

func shake_vertical(node: Node, orig_pos: Vector2, strength: float = 10, duration: float = 0.4):
	if not node:
		return

	var shake_count := 10
	var tween := create_tween()

	for i in shake_count:
		var offset := Vector2(0, randf_range(-1.0, 1.0))
		var target := orig_pos + offset * strength
		if i % 2 == 0:
			target = orig_pos
		tween.tween_property(node, "position", target, duration / float(shake_count))
		strength *= 0.75

	tween.finished.connect(func(): node.position = orig_pos)

func shake_horizontal(node: Node, orig_pos: Vector2, strength: float = 10, duration: float = 0.4):
	if not node:
		return

	var shake_count := 10
	var tween := create_tween()

	for i in shake_count:
		var offset := Vector2(randf_range(-1.0, 1.0), 0)
		var target := orig_pos + offset * strength
		if i % 2 == 0:
			target = orig_pos
		tween.tween_property(node, "position", target, duration / float(shake_count))
		strength *= 0.75

	tween.finished.connect(func(): node.position = orig_pos)
