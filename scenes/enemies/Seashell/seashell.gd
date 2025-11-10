extends CharacterBody2D

@export var jump_force: float = -400.0
@export var jump_interval: float = 2.0
@export var gravity: float = 980.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_timer: Timer = $JumpTimer

func _ready():
	add_to_group("enemies")

	jump_timer.wait_time = jump_interval
	jump_timer.timeout.connect(_on_jump_timer_timeout)
	jump_timer.start()

	if sprite:
		sprite.play("Idle")

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	move_and_slide()

func _on_jump_timer_timeout():
	if is_on_floor():
		velocity.y = jump_force
		#Agregar animacion de salto
