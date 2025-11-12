extends Resource
class_name LevelData

@export var level_id: int
@export var level_name: String
@export var scene_path: String
@export var abilities_in_level: Array[String] = []
@export_multiline var description: String = ""