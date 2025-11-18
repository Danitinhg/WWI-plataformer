extends Area2D

@export var checkpoint_id: int = 0
var is_activated: bool = false

@onready var sprite = $AnimatedSprite2D

func _ready():
    add_to_group("checkpoints")
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
    if body.is_in_group("plsyer") and not is_activated:
        activate()

func activate():
    is_activated = true
    print("Checkpoint puesto en: ", global_position)

    var level = get_parent()
    if level.has_method("activate_checkpoint"):
        level.activate_checpoint(global_position)

    change_visual()

func change_visual():
    if sprite and sprite is AnimatedSprite2D:
        sprite.play("activate")

func desactivate():
    is_activated = false

    if sprite and sprite is AnimatedSprite2D:
        sprite.play("inactive")
    elif sprite:
        sprite.modulate = Color(1, 1, 1)