extends Node2D
class_name AbilityBase

var player: CharacterBody2D

func putAbility(player_node: CharacterBody2D):
	player = player_node

func physics_update(_delta: float) -> bool:
	return false

func get_animation_name() -> String:
	return ""

func activate():
	pass