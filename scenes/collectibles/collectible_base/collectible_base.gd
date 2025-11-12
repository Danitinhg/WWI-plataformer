extends Area2D
class_name Collectible

signal collected(collectible)

@export var collectible_id: int = 0

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    if body.is_in_group("player") and body.has_method("collect_item"):
        body.collect_item(self)

func collect():
    collected.emit(self)
    # Espacio para implmentar particulas o sonidos que haga el coleccionable
    queue_free()