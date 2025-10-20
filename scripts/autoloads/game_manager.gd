extends Node

signal level_completed(level_id: int)

var levels: Array[LevelData] = []
var all_abilities: Array[String] = ["DoubleJump", "Dash", "Reflect"]
var current_level: int = -1
var current_level_ablities: Array[String] = []

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

	#🗣️🔥 Solo para el nivel de prueba🗣️🔥
	if level_id == -1:
		current_level_ablities = all_abilities.duplicate()
		get_tree().change_scene_to_file("res://level_test.tscn")
		return
	#🗣️🔥 Solo para el nivel de prueba🗣️🔥

	var level_data = levels[level_id]
	current_level_ablities = level_data.abilities_in_level.duplicate()
	get_tree().change_scene_to_file(level_data.scene_path)

func complete_level():
	if current_level == -1:
		return

	levels[current_level].completed = true
	level_completed.emit(current_level)
	PlayerData.save_game()

func return_to_level_selector():
	current_level = -1
	current_level_ablities.clear()
	get_tree().change_scene_to_file("res://scenes/ui/level_selector/level_selector.tscn")

func get_level_abilities() -> Array[String]:
	return current_level_ablities
