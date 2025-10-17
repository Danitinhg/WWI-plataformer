extends Resource
class_name LevelData

@export var level_id: int
@export var level_name: String
@export var scene_path: String
@export var completed: bool = false
@export var abilities_in_level: Array[String] = []
@export_multiline var description: String = ""
@export var total_collectibles: int = 3
@export var collected_count: int = 0
