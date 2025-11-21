extends Area2D
class_name Coin

@onready var sprite = $AnimatedSprite2D

func _ready():
    add_to_group("coins")
    body_entered.connect(_on_body_entered)

    if sprite:
        sprite.play("idle")

func _on_body_entered(body):
    if body.is_in_group("player"):
        collect()

func collect():
    #se cuenta en hud
    get_tree().call_group("hud", "add_coin")
    queue_free()  #Destruir la moneda