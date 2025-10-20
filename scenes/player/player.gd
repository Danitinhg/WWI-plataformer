extends CharacterBody2D

#Movimiento básico del player, moverse y saltar
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0
@export var acceleration: float = 1000.0
@export var friction: float = 1200.0

#Giro en el aire 
@export var spin_duration: float = 0.5
@export var spin_gravity_multiplier: float = 0.3
var is_spinning: bool = false
var spin_timer: float = 0.0
var can_spin: bool = false

#Habilidades de los niveles
var abilities: Array = []
var current_ability_index: int = 0

@onready var sprite = $Sprite2D

func _ready():
	add_to_group("player")
	load_level_ability()

func load_level_ability():
	var level_ability_names = GameManager.get_level_abilities()
	
	for ability_name in level_ability_names:
		add_ability(ability_name)

func add_ability(ability_name: String):
	var ability_path = "res://scenes/player/abilities/" + ability_name + ".tscn"
	
	if ResourceLoader.exists(ability_path):
		var ability_scene = load(ability_path)
		var ability = ability_scene.instantiate()
		add_child(ability)
		abilities.append(ability)
	else:
		print("no hay habilidad")

func _physics_process(delta):
	if not is_on_floor():
		if is_spinning:
			velocity.y += gravity * spin_gravity_multiplier * delta
		else:
			velocity.y += gravity * delta
		
		if spin_timer > 0:
			spin_timer -= delta
			if spin_timer <= 0:
				is_spinning = false
	else:
		can_spin = false
		is_spinning = false

	#Saltar
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		can_spin = true
	
	#Giro en el aire
	if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and can_spin and not is_spinning:
		start_spin()
	
	#Gestión de habilidades
	if abilities.size() > 1 and Input.is_action_just_pressed("cycle_ability"):
		current_ability_index = (current_ability_index + 1) % abilities.size()
		print("Habilidad seleccionada: " + abilities[current_ability_index].name)

	if not abilities.is_empty():
		var selected_ability = abilities[current_ability_index]
		if selected_ability.has_method("handle_input"):
			selected_ability.handle_input(self, delta)

	#Movimiento horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	move_and_slide()
	
func start_spin():
		is_spinning = true
		can_spin = false
		spin_timer = spin_duration
		#cuando esten los sprites girar el sprite para que sea un giro de verdad (en esta linea)

func collect_item2(collectible):
	PlayerData.add_collectible(GameManager.current_level, collectible.collectible_id)
