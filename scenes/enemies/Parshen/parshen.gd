extends EnemyBase

@export var projectile_scene: PackedScene

@onready var shoot_timer = $Timer
@onready var kyanon = $Toge_Kyanon

#func _ready():
	#shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _on_shoot_timer_timeout():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()

		get_tree().current_scene.add_child(projectile)
		projectile.global_position = kyanon.global_position

		if animated_sprite.flip_h:
			projectile.direction = Vector2.LEFT
		else:
			projectile.direction = Vector2.RIGHT