class_name Damageable extends Node

signal on_hit()

@export var character : CharacterBody2D

func hit():
	emit_signal("on_hit")
