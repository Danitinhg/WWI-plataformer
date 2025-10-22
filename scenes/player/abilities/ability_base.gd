extends Node2D
class_name AbilityBase

var player: CharacterBody2D

func putAbility(player_node: CharacterBody2D):
	player = player_node

func process(_delta: float):
	pass

func activate():
	pass