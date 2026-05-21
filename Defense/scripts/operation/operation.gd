extends Node

const MAX_ENTRY := 6

const ELEMENT_SCENE := preload("res://scenes/operation/element.tscn")
const ENEMY_INFO_SCENE := preload("res://scenes/operation/enemy_info.tscn")

# item list and entry.
@onready var item_list: FlowContainer = %ItemList
@onready var item_entry: HBoxContainer = %ItemEntry

# focused info.
@onready var select_info = %SelectInfo
@onready var select_icon: TextureRect = %SelectIcon
@onready var select_id: Label = %SelectID
@onready var select_description: Label = %SelectDescription

# about enemies.
@onready var stage_enemy_info: HBoxContainer = %StageEnemyInfo

func _ready() -> void:
	select_info.hide()
	#set_stage_enemy_info()
	
	# load all items(purchased items too).
	for item_data : ItemData in Pool.item_pool:
		add_to_list(item_data)
	for item_data : ItemData in GameManager.purchased_items:
		# if item data is effective item, then not add to list...
		add_to_list(item_data)

func add_to_list(data : ItemData):
	if GameManager.game_progress < data.unlock_stage:
		return
	
	var elem := create_element_inst(data)
	elem.mouse_entered.connect(show_info.bind(data))
	elem.mouse_exited.connect(hide_info)
	elem.pressed.connect(add_to_entry.bind(elem))
	
	item_list.add_child(elem)

func add_to_entry(list_elem : Element):
	if GameManager.picked_items.size() == MAX_ENTRY:
		return
	
	list_elem.disabled = true
	
	var entry_elem := create_element_inst(list_elem.data)
	entry_elem.mouse_entered.connect(show_info.bind(list_elem.data))
	entry_elem.mouse_exited.connect(hide_info)
	entry_elem.pressed.connect(erase_entry_elem.bind(list_elem, entry_elem))
	
	GameManager.picked_items.append(list_elem.data)
	item_entry.add_child(entry_elem)

func erase_entry_elem(list_elem : Element, entry_elem : Element):
	GameManager.picked_items.erase(entry_elem.data)
	entry_elem.queue_free()
	
	list_elem.disabled = false

func create_element_inst(data : ItemData) -> Element:
	var inst := ELEMENT_SCENE.instantiate()
	inst.data = data
	return inst

func set_stage_enemy_info():
	for enemy_unit_data in GameManager.stage_data.stage_enemies:
		var enemy_info := ENEMY_INFO_SCENE.instantiate()
		enemy_info.data = enemy_unit_data
		stage_enemy_info.add_child(enemy_info)

func show_info(data : ItemData):
	select_icon.texture = data.sprite
	select_id.text = data.id
	# select_description.text = data.description
	
	select_info.show()

func hide_info():
	select_info.hide()

func _on_next_pressed():
	SceneManager.change_scene(SceneManager.GameScene.STAGE)

func _on_before_pressed():
	SceneManager.change_scene(SceneManager.GameScene.MAP)
