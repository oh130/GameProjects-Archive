class_name Halo extends BoardObject

func init_halo(_halo_info : Dictionary):
	coord = Vector2i(_halo_info["pos"][0], _halo_info["pos"][1])
	
	texture = Global.halo_textures[0]
	
	material.resource_local_to_scene = true
