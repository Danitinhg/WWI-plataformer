extends Node2D

@export var level_id: int = 1
var player: CharacterBody2D

func _ready():
	var player_scene = load("res://scenes/player/player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	
	# spawn del jugador
	var spawn = $PlayerSpawn
	player.global_position = spawn.global_position
	
	#quitar los items ya recogidos
	hide_collected_items()

func hide_collected_items():
	for item in $Items.get_children():
		if item is Collectible:
			if PlayerData.is_collectible_collected(level_id, item.collectible_id):
				item.queue_free()

func _on_star_collected(collectible):
	PlayerData.add_collectible(level_id, collectible.collectible_id)


func _on_collectible_base_collected(collectible: Variant) -> void:
	pass


func _on_collectible_base_2_collected(collectible: Variant) -> void:
	pass


func _on_collectible_base_3_collected(collectible: Variant) -> void:
	pass
