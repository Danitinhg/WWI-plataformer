extends Node2D
class_name LevelBase

@export var level_data: LevelData
var player_scene = preload("res://scenes/player/player.tscn")
var player: CharacterBody2D

func _ready():
	player = player_scene.instantiate()
	add_child(player)
	if level_data:
		hide_collected_items()
		PlayerData.current_level_id = level_data.level_id

func hide_collected_items():
	var collectibles = get_tree().get_nodes_in_group("collectibles")
	for collectible_index in range(level_data.collectibles.size()):
		if level_data.collectibles[collectible_index]:
			collectibles[collectible_index].queue_free()