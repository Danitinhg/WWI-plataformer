extends CharacterBody2D
class_name EnemyBase

const SPEED = 150.0

var move_direction = 1

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	if animated_sprite:
		animated_sprite.flip_h = move_direction < 0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += get_gravity() * delta

	velocity.x = move_direction * SPEED

	move_and_slide()

	if is_on_wall():
		move_direction *= -1
		if animated_sprite:
			animated_sprite.flip_h = move_direction < 0