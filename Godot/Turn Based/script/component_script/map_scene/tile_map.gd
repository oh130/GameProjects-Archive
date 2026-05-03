extends TileMap

@onready var player_party = $"../PlayerParty"
@onready var node = $"../Node"

@export var tile_area : PackedScene

const main_layer = 0
const main_atlas_id = 0

var pos_to_tile_dict : Dictionary
var movable_pos : Array[Vector2i]

func _ready():
	for cellpos in get_used_cells(0):
		var cell : int = get_cell_source_id(0, cellpos)
		if cell == 0:
			var area : TileArea = tile_area.instantiate()
			var global_pos = to_global(map_to_local(cellpos))
			node.add_child(area)
			area.tile_init(self, cellpos)
			area.position = global_pos
			pos_to_tile_dict[cellpos] = area
	
	player_party_move_to(Vector2i(0,0))
	refresh_movable_pos(Vector2i(0,0))

func player_party_move_to(pos : Vector2i):
	set_cell(main_layer, pos, main_atlas_id, Vector2i(0,0), 2)
	player_party.position = to_global(map_to_local(pos))
	
	var event_idx : int = pos_to_tile_dict[pos].visit()
	if pos != Vector2i(0,0):
		GlobalSignal.emit_signal("map_event_occur", event_idx)
	
	refresh_movable_pos(pos)

func refresh_movable_pos(cur_pos : Vector2i):
	for pos in movable_pos:
		pos_to_tile_dict[pos].movable = false
	
	movable_pos.clear()
	
	for pos in get_surrounding_cells(cur_pos):
		if get_cell_alternative_tile(main_layer, pos) > -1:
			movable_pos.append(pos)
			pos_to_tile_dict[pos].movable = true

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var pos_clicked = local_to_map(to_local(event.position))
			if pos_clicked in movable_pos:
				set_cell(main_layer, local_to_map(to_local(player_party.position)), main_atlas_id, Vector2i(0,0), 0)
				player_party_move_to(pos_clicked)
