class_name Focus extends TileMapLayer

@onready var actor_reach: TileMapLayer = %ActorReach

func clickable_focus(coord : Vector2i):
	set_cell(coord, 0, Vector2i.ZERO, 1)

func show_move_reach(coords : Array[Vector2i]):
	total_clear()
	for coord in coords:
		actor_reach.set_cell(coord, 0, Vector2i.ZERO, 2)

func show_attack_reach(coords : Array[Vector2i]):
	total_clear()
	for coord in coords:
		actor_reach.set_cell(coord, 0, Vector2i.ZERO, 3)

func total_clear():
	clear()
	actor_reach.clear()
