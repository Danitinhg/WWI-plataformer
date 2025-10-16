extends Resource
class_name LevelData

@export var level_id: int
@export var level_name: String
@export var scene_path: String
@export var unlocked: bool = false
@export var completed: bool = false
@export var unlocks_ability: String = ""
@export var total_collectibles: int = 3
@export var collected_count: int = 0
@export var required_level: int = -1 # -1 = no requiere nivel previo
@export_multiline var description: String = ""
