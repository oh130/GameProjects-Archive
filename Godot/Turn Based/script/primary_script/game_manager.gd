extends Node2D

var map_scene : Node2D
var place : Node2D

var player_sc_container : Array[StatusController] = [null, null, null, null]

func connect_signals():
	GlobalSignal.map_event_occur.connect(place_event)

func init_game_manager(roster_arr : Array[String]):
	map_scene = get_child(0)
	place = get_child(1)
	
	active_map_scene()
	connect_signals()
	
	for i in roster_arr.size():
		if roster_arr[i] != Enum.EMPTY:
			var new_unit : StatusController = GlobalData.unit_scene.instantiate()
			new_unit.unit_created(roster_arr[i], i, false)
			player_sc_container[i] = new_unit

func place_event(event_idx : int):
	match event_idx:
		Enum.MapEvents.NOTHING:
			return
		Enum.MapEvents.COMBAT:
			place.combat_start(player_sc_container)
	
	active_place()

func active_map_scene():
	map_scene.process_mode = Node.PROCESS_MODE_INHERIT
	map_scene.show()
	place.hide()
	place.process_mode = Node.PROCESS_MODE_DISABLED

func active_place():
	place.process_mode = Node.PROCESS_MODE_INHERIT
	place.show()
	map_scene.hide()
	map_scene.process_mode = Node.PROCESS_MODE_DISABLED
