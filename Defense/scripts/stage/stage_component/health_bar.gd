class_name HealthBar extends Control

const HEALTH_BLOCK_SCENE := preload("res://scenes/stage/ui/health_block.tscn")

@onready var health_blocks: HBoxContainer = %HealthBlocks

var pos : Vector2

func show_health_bar(val : int, max_val : int):
	for child in health_blocks.get_children():
		health_blocks.remove_child(child)
	
	var block_size : Vector2
	
	match max_val:
		1:
			size = Vector2(30,20)
			block_size = Vector2(20,10)
		2:
			size = Vector2(40,20)
			block_size = Vector2(14,10)
		_:
			size = Vector2(50,20)
			block_size = Vector2(12, 10)
	
	health_blocks.size = size - Vector2(10,10)
	
	for i in val:
		var block := HEALTH_BLOCK_SCENE.instantiate()
		block.custom_minimum_size = block_size
		health_blocks.add_child(block)
	
	position = pos - size / 2
	show()
