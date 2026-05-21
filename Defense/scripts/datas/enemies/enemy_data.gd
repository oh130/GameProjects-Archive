class_name EnemyData extends Resource

@export_group("Preview Infoes")
@export var id : String
@export var sprite : Texture2D

@export_group("Spawn infos")
@export var enemy : PackedScene
@export var tier : int

@export_group("In-Game attributes")
@export var mobility : int
@export var reach : int
@export var damage : int
@export var max_health : int
@export var armored : bool
