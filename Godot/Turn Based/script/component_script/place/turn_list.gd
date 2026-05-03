class_name TurnList extends HBoxContainer

var turn_list_portraits : Array[Node]
var died_unit : Array[StatusController]

signal proceed_turn_end()

func _ready():
	connect_signals()

func connect_signals():
	GlobalSignal.unit_died.connect(unit_died)

func period_start():
	modulate.a = 0
	
	await get_tree().create_timer(0.3).timeout
	
	for child in get_children():
		if is_instance_valid(child):
			turn_list_portraits.append(child)
	
	var tween : Tween = create_tween()
	tween.tween_property(self, "modulate", Color(modulate.r, modulate.g, modulate.b, 1), 0.1)
	
func proceed_turn() -> Signal:
	var pos_arr : Array[Vector2]
	var exist_node : Array[Node]
	var del_node : Array[Node]
	
	var mod : int = 0
	for i in turn_list_portraits.size():
		if i == 0 or turn_list_portraits[i].portrait_unit in died_unit:
			if i != 0:
				del_node.append(turn_list_portraits[i])
			var tween : Tween = create_tween()
			tween.tween_property(turn_list_portraits[i], "modulate", Color(modulate.r, modulate.g, modulate.b, 0), 0.1)
		else:
			exist_node.append(turn_list_portraits[i])
			pos_arr.append(Vector2(global_position.x + turn_list_portraits[i].get_size().x * mod, global_position.y))
			mod += 1
	
	died_unit.clear()
	
	await get_tree().create_timer(0.1).timeout
	
	for i in exist_node.size():
		var tween : Tween = create_tween()
		tween.tween_property(exist_node[i], "global_position", pos_arr[i], 0.2)
	
	await get_tree().create_timer(0.2).timeout
	
	turn_list_portraits.remove_at(0)
	get_child(0).queue_free()
	
	for i in range(del_node.size() - 1, -1, -1):
		while turn_list_portraits.find(del_node[i]) != -1:
			turn_list_portraits.erase(del_node[i])
		del_node[i].queue_free()
	
	return proceed_turn_end

func unit_focus(unit : StatusController):
	if unit == null:
		return
	
	for i in turn_list_portraits.size():
		if turn_list_portraits[i].portrait_unit == unit:
			var tween : Tween = create_tween()
			var target_pos : Vector2 = Vector2(global_position.x + turn_list_portraits[0].get_size().x * i, global_position.y - 0.25 * turn_list_portraits[0].get_size().y)
			tween.tween_property(turn_list_portraits[i], "global_position", target_pos, 0.2)

func unit_unfocus(unit : StatusController):
	if unit == null:
		return
		
	for i in turn_list_portraits.size():
		if turn_list_portraits[i].portrait_unit == unit:
			var tween : Tween = create_tween()
			var cur_pos : Vector2 = Vector2(global_position.x + turn_list_portraits[0].get_size().x * i, global_position.y)
			tween.tween_property(turn_list_portraits[i], "global_position", cur_pos, 0.2)

func unit_died(unit : StatusController):
	died_unit.append(unit)
