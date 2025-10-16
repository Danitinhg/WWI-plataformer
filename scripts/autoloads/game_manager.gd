extends Node

#Comunicación entre nodos
signal level_completed(level_id: int)
signal ability_unlocked(ability_name: String)

var levels: Array[LevelData] = []
var current_level: int = -1

func _ready():
	load_levels()

func load_levels():
	levels = [
		load("res://resources/levels/level_01_data.tres"),
		load("res://resources/levels/level_02_data.tres"),
		load("res://resources/levels/level_03_data.tres")
	]

func load_level(level_id: int):
	current_level = level_id
	var level_data = levels[level_id]
	get_tree().change_scene_to_file(level_data.scene_path)

func complete_level(level_id: int):
	levels[level_id].completed = true
   
	# Desbloquear habilidad
	var ability = levels[level_id].unlocks_ability
	if ability != "":
		PlayerData.unlock_ability(ability)
		ability_unlocked.emit(ability)
	
	level_completed.emit(level_id)
	PlayerData.save_game()

#func return_to_level_selector():
	#get_tree().change_scene_to_file("res://scenes/ui/le")
	
	
