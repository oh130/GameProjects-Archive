class_name Rewards extends Control

@onready var reward_container: GridContainer = %RewardContainer

func _ready():
	hide()
	
	EventBus.hide_reward.connect(hide)

func show_rewards():
	var chosen_elems : Array[ElementData] = []
	
	for elem_sample : ElemSample in reward_container.get_children():
		var reward_elem := Pool.element_pool[Random.get_randi(Pool.element_pool.size())]
		while chosen_elems.has(reward_elem):
			reward_elem = Pool.element_pool[Random.get_randi(Pool.element_pool.size())]
		
		chosen_elems.append(reward_elem)
		elem_sample.data = reward_elem
	
	show()

func pass_reward():
	EventBus.reward_selected.emit()
	hide()
