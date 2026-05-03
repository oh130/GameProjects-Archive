class_name RouteChoice extends CanvasLayer

const MAXIMUM_PROGRESS := 15
const ELITE_APPEAR_PROGRESS := 4
const ELITE_TERM := 2
const ELITE_ALWAYS_TERM := 4
const SHOP_APPEAR_PROGRESS := 10 # shop == before boss.

const WEIGHT :=\
{
	Enum.Route.ENEMY_MORE_EXP: 5,
	Enum.Route.ENEMY_MORE_GOLD: 5,
	Enum.Route.ENEMY_MORE_EQUIPMENT: 5,
	Enum.Route.ENCOUNTER: 9,
	Enum.Route.ELITE: 6
}

@onready var route_container: HBoxContainer = %RouteContainer

var route_blocks : Array[RouteBlock]

signal route_entered(route : Enum.Route)
signal chapter_ended()

func _ready():
	hide()
	
	for child : RouteBlock in route_container.get_children():
		route_blocks.append(child)
		child.pressed.connect(route_block_clicked.bind(child))
		hide()

func proceed_run(route : Enum.Route):
	DataManager.save_data.cleared_routes.append(DataManager.save_data.current_route)
	DataManager.save_data.current_route = route
	DataManager.save_data.progress += 1
	
	DataManager.save_data.difficulty += 3
	
	match route:
		Enum.Route.ELITE:
			DataManager.save_data.since_last_elite_visit = 0
		Enum.Route.CHAPTER_EXIT:
			DataManager.save_data.progress = 0
			DataManager.save_data.since_last_elite_visit = 0
			chapter_ended.emit()
	
	DataManager.save_game()

func route_block_clicked(route_block : RouteBlock):
	proceed_run(route_block.route)
	route_entered.emit(route_block.route)

func get_next_routes():
	if DataManager.save_data.progress == MAXIMUM_PROGRESS:
		display_routes([Enum.Route.SHOP])
		return
	
	if DataManager.save_data.current_route == Enum.Route.SHOP:
		display_routes([Enum.Route.BOSS])
		return
	
	if DataManager.save_data.current_route == Enum.Route.BOSS:
		display_routes([Enum.Route.CHAPTER_EXIT])
		return
	
	var considered_routes : Array[Enum.Route] =\
	[
		Enum.Route.ENEMY_MORE_EXP,
		Enum.Route.ENEMY_MORE_GOLD,
		Enum.Route.ENEMY_MORE_EQUIPMENT,
		Enum.Route.ENCOUNTER
	]
	var decided_routes : Array[Enum.Route]
	
	if DataManager.save_data.progress >= ELITE_APPEAR_PROGRESS\
	and DataManager.save_data.since_last_elite_visit >= ELITE_TERM:
		if DataManager.save_data.since_last_elite_visit >= ELITE_ALWAYS_TERM:
			decided_routes.append(Enum.Route.ELITE)
		else:
			considered_routes.append(Enum.Route.ELITE)
	
	if DataManager.save_data.progress >= SHOP_APPEAR_PROGRESS:
		decided_routes.append(Enum.Route.SHOP)
	
	var route_num := 2 if Random.get_randi(2) else 3
	var remain_route_num := route_num - decided_routes.size()
	
	if considered_routes.size() <= remain_route_num:
		display_routes(considered_routes + decided_routes)
		return
	
	while remain_route_num > 0:
		remain_route_num -= 1
		
		var picked_route := pick_rand_route(considered_routes)
		considered_routes.erase(picked_route)
		decided_routes.append(picked_route)
	
	display_routes(decided_routes)

func pick_rand_route(route_arr : Array[Enum.Route]) -> Enum.Route:
	var ret : Enum.Route
	var accumulated := 0
	for route in route_arr:
		accumulated += WEIGHT[route]
	
	var rand_i := Random.get_randi(accumulated)
	accumulated = 0
	
	for route in route_arr:
		accumulated += WEIGHT[route]
		if rand_i < accumulated:
			ret = route
			break
	
	return ret

func display_routes(routes : Array[Enum.Route]):
	var i := 0
	for route_block in route_blocks:
		if i >= routes.size():
			route_block.hide()
		else:
			route_block.route = routes[i]
			route_block.show()
		
		i += 1
