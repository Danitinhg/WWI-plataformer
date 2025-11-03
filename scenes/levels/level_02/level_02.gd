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
	
	#Gestión de los coleccionables recogidos en el nivekl
	var level_data = GameManager.levels[level_id]
	var collected_in_level = PlayerData.get_collected_for_level(level_id)
	for k in range(level_data.big_coins_collected.size()):
		if k in collected_in_level:
			level_data.big_coins_collected[k] = true
	
	#quitar los items ya recogidos
	hide_collected_items()

func hide_collected_items():
	for item in $Items.get_children():
		if item is Collectible:
			if PlayerData.is_collectible_collected(level_id, item.collectible_id):
				item.queue_free()

#Actualiza la información de los coleccionables
func _on_collectible_base_collected(collectible: Variant) -> void:
	var level_data = GameManager.levels[level_id]
	
	if collectible.collectible_id >= 0 and collectible.collectible_id < level_data.big_coins_collected.size():
		level_data.big_coins_collected[collectible.collectible_id] = true
		print("Moneda %s del nivel %s recogida" % [collectible.collectible_id, level_id])

	print("Se conecto la señal para: " + collectible.name)