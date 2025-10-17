extends Area2D
class_name Collectible

signal collected(collectible)

@export var collectible_id: int = 0
@export var points_value: int = 1

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		collect()

func collect():
	collected.emit(self)
	# Espacio para implentar particulas o sonidos que haga el coleccionable
	queue_free()
