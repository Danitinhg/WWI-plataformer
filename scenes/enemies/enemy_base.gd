extends CharacterBody2D
class_name EnemyBase

#Señales
signal enemy_dead

#Sistema de visa
@export var max_health: int = 1
var current_health: int = 1
var is_dying: bool = false
const SPEED = 150.0

var move_direction = 1
var can_walk = true

@onready var animated_sprite = $AnimatedSprite2D
@onready var wall_raycast = $RayCast2D

func _ready():
	current_health = max_health
	add_to_group("enemies")

func _physics_process(delta):
	#Temporal: Y para probar el daño
	if Input.is_action_just_pressed("test_damage_enemy"):
		take_damage(1)
		
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

func take_damage(damage: int):
	if is_dying:
		return

	current_health -= damage
	current_health = max(current_health, 0)

	print(name, " recibio daño " , current_health, "/", max_health)

	if current_health <= 0:
		die()

func die():
	if is_dying:
		return

	is_dying = true
	enemy_dead.emit()

	print(name, " murio")

	set_physics_process(false)

	#Añadir animacion de muerte mas adelante
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
