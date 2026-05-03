extends Node

@onready var table = $"../.."
@onready var devil = $"../Devil"
@onready var atk_area_container = $"../../AtkAreaContainer"

var halo_scene : PackedScene = preload("res://scenes/instances/halo.tscn")

signal halo_caught()

func create_halos(cur_chap : int, cur_level : int):
	var halo_infoes : Array = Level.level_info[str(cur_chap)][str(cur_level)]["haloes"]
	
	for child in get_children():
		remove_child(child)
	
	for info in halo_infoes:
		var halo : Halo = halo_scene.instantiate()
		add_child(halo)
		halo.init_halo(info)

func devil_move_ended(_coord : Vector2i):
	for halo : Halo in get_children():
		if halo.coord == _coord:
			remove_child(halo)
			emit_signal("halo_caught")
