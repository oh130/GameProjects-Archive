class_name Statue extends Enemy

func init_statue(_statue_info : Dictionary):
	coord = Vector2i(_statue_info["pos"][0], _statue_info["pos"][1])
	piece_type = _statue_info["type"]
	
	texture = Global.statue_textures[piece_type]
	
	material.resource_local_to_scene = true
