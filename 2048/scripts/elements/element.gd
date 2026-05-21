class_name Element extends Control

const PROPERTY_UI_SCENE := preload("res://scenes/run/property_ui.tscn")
const BOARD_SEPARATE := 130

@onready var grade_label = %GradeLabel
@onready var property_ui: GridContainer = %PropertyUI

var cur_coord : Vector2i
var grade : int : set = set_grade
var properties : Dictionary[Property, int]
var added_property_ui : Dictionary[Property, PropertyUI]

func set_grade(value : int):
	grade = value
	
	if not is_node_ready():
		await ready
	
	grade_label.text = str(grade)

func init_element(data : ElementData):
	grade = data.grade
	properties = data.properties.duplicate()
	
	for prop in properties:
		var inst := PROPERTY_UI_SCENE.instantiate()
		property_ui.add_child(inst)
		inst.init_property_ui(prop, properties[prop])
		
		added_property_ui[prop] = inst

func load_element(saved_elem : Element):
	cur_coord = saved_elem.cur_coord
	position = calculate_pos(cur_coord)
	
	grade = saved_elem.grade
	properties = saved_elem.properties.duplicate()
	
	for prop in properties:
		var inst := PROPERTY_UI_SCENE.instantiate()
		property_ui.add_child(inst)
		inst.init_property_ui(prop, properties[prop])
		
		added_property_ui[prop] = inst

func calculate_pos(coord : Vector2i) -> Vector2:
	return BOARD_SEPARATE * coord

func created_on_board(coord : Vector2i):
	cur_coord = coord
	position = calculate_pos(coord)
	
	animate_appear()

func combine(combined_properties : Dictionary[Property, int]):
	grade += 1
	
	for prop in combined_properties.keys():
		if prop.extinction:
			continue
		
		if properties.has(prop):
			if prop.stackable:
				properties[prop] += combined_properties[prop]
				added_property_ui[prop].amount = properties[prop]
		else:
			properties[prop] = combined_properties[prop]
			
			var inst := PROPERTY_UI_SCENE.instantiate()
			property_ui.add_child(inst)
			inst.init_property_ui(prop, properties[prop])
			
			added_property_ui[prop] = inst
	
	animate_zoom(Vector2(1.25,1.25), 0.25, true)

func combined_at(elem : Element):
	z_index = 0
	await move_to(elem.cur_coord)
	
	elem.combine(properties)
	queue_free()

func move_to(dest : Vector2i):
	cur_coord = dest
	
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", calculate_pos(dest), 0.2)
	await tween.finished

func animate_appear():
	scale = Vector2i(0, 0)
	modulate = Color(1, 1, 1, 0)
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)
	animate_zoom(Vector2i(1, 1), 0.25, false)

func animate_zoom(target_scale : Vector2 = Vector2(1.25, 1.25), time : float = 0.25, back := true):
	var origin_scale := scale
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", target_scale, time)
	if back:
		tween.chain().tween_property(self, "scale", origin_scale, time)

func _on_mouse_entered():
	pass

func _on_mouse_exited():
	pass
