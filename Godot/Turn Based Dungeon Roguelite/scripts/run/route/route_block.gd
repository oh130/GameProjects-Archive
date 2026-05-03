class_name RouteBlock extends Button

@onready var route_background: TextureRect = %RouteBackground
@onready var route_icon: TextureRect = %RouteIcon

@export var route_icon_textures : Dictionary[Enum.Route, Texture2D]

var route : Enum.Route : set = set_route

func set_route(value : Enum.Route):
	route = value
	route_icon.texture = route_icon_textures[value]
