extends Area2D

@export var damage: int = 1
@export var knockback_force: float = 200.0

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
    if body.is_in_group("player"):
        var knockback_direction = Vector2(0, -1)

        if body.has_method("take_damage"):
            body.take_damage(damage, knockback_direction * knockback_force)
            print("Spike hizo daño al player")
