class_name Equipment extends Item

@export var is_unique : bool
@export var stats : Dictionary[Enum.Stat, Amount]
@export var party_stats : Dictionary[Enum.PartyStat, int]
@export var passives : Array[Passive]
