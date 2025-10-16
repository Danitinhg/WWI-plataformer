extends CharacterBody2D

#Movimiento básico del player, moverse y saltar
@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0

#Giro en el aire (¡Viiup!)
@export var spin_duration: float = 0.5
@export var spin_gravity_multiplier: float = 0.3
var is_spinning: bool = false
var spin_timer: float = 0.0
var can_spin: bool = false

#Habilidades de los niveles
var abilities: Array = []

@onready var sprite = $Sprite2D

func _ready():
	add_to_group("player")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if is_spinning:
			velocity.y += gravity * spin_gravity_multiplier * delta
		else:
			velocity.y += gravity * delta
	else:
		#Al tocar el suelo, el jugador tiene disponible de nuevo el giro
		can_spin = false
		is_spinning = false

	#Saltar
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		can_spin = true
	
	#Giro en el aire (pulsar de nuevo el boton de salta en el aire)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and can_spin and not is_spinning:
		start_spin()
	
	#Movimiento horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	
func start_spin():
		is_spinning = true
		can_spin = true
		spin_timer = spin_duration
		#Cuando se usen los sprites poner en esta linea que gire el player

func collect_item(collectible):
	PlayerData.add_collectible(collectible.collectible_id)
