class_name Property extends Resource

@export_group("Information")
@export var id : String
@export var icon : Texture
@export_multiline var description : String

@export_group("In Game")
@export var property_id : Board.PropertyID
@export var stackable := true
@export var extinction : bool
@export var has_grade_limit : bool
