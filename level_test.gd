extends Node2D

@onready var player = $Player

func _ready():
	#Se añaden las habiliddades del player manualmente
	var all_abilities = ["Dash", "DoubleJump", "Reflect"]
	for ability_name in all_abilities:
		player.add_ability(ability_name)
