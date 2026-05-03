class_name TileArea extends Area2D

var events : Node2D

var tile_map : TileMap
var coordinate : Vector2i
var movable : bool

var tile_event : int = Enum.MapEvents.NOTHING

func tile_init(_tile_map : TileMap, _coord : Vector2i):
	events = get_child(1)
	tile_map = _tile_map
	coordinate = _coord
	
	if _coord != Vector2i(0,0): 
		if randi_range(0,99) < 20:
			tile_event = Enum.MapEvents.COMBAT
			var combat_tile = GlobalData.combat_tile.instantiate()
			events.add_child(combat_tile)

func visit() -> int:
	var ret : int = tile_event
	
	if tile_event != Enum.MapEvents.NOTHING:
		tile_event = Enum.MapEvents.NOTHING
		events.get_child(0).queue_free()
	
	return ret

func _on_mouse_entered():
	if not movable:
		return
	
	var current_atlas_coords = tile_map.get_cell_atlas_coords(0, coordinate)
	var current_tile_alt = tile_map.get_cell_alternative_tile(0, coordinate)
	if current_tile_alt > -1:
		var number_of_alts_for_clicked = tile_map.tile_set.get_source(0)\
				.get_alternative_tiles_count(current_atlas_coords)
		tile_map.set_cell(0, coordinate, 0, current_atlas_coords, 1)

func _on_mouse_exited():
	if not movable:
		return
	
	var current_atlas_coords = tile_map.get_cell_atlas_coords(0, coordinate)
	var current_tile_alt = tile_map.get_cell_alternative_tile(0, coordinate)
	if current_tile_alt > -1:
		tile_map.set_cell(0, coordinate, 0, current_atlas_coords, 0)
