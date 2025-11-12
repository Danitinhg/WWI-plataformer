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

func hide_collected_items():
	var collectibles = get_tree().get_nodes_in_group("collectibles")

	for collectible in collectibles:
		if collectible.collectible_id != null:
			if PlayerData.is_collectible_collected(level_data.level_id, collectible.collectible_id):
				collectible.queue_free()