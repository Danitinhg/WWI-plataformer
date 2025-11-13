extends CharacterBody2D
class_name EnemyBase

const SPEED = 150.0

var move_direction = 1
var can_walk = true

@onready var animated_sprite = $AnimatedSprite2D
@onready var wall_raycast = $RayCast2D

func _ready():
	add_to_group("enemies")

func _physics_process(delta):
	if animated_sprite:
		animated_sprite.flip_h = move_direction > 0

	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	if can_walk:
		velocity.x = move_direction * SPEED

	move_and_slide()

	if wall_raycast.is_colliding():
		move_direction *= -1
		wall_raycast.target_position.x *= -1
