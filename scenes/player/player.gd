extends CharacterBody2D

# Movimiento básico del player
@export_group("Movimiento")
@export var speed: float = 100.0
@export var acceleration: float = 250.0
@export var friction: float = 800.0

#Salto
@export_group("Salto")
@export var jump_velocity: float = -350.0
@export var gravity: float = 980.0
#Animaciones antes y despues del salto
var is_landing: bool = false
var is_anticipating: bool = false
var was_in_air: bool = false
var jump_was_pressed: bool = false

# Giro en el aire
@export_group("Spin")
@export var spin_duration: float = 0.5
@export var spin_gravity_multiplier: float = 0.3

var is_spinning: bool = false
var spin_timer: float = 0.0
var can_spin: bool = false

# Coyote Time y Jump Buffer
@export_group("Controles Avanzados")
@export var coyote_time_duration: float = 0.15
@export var jump_buffer_duration: float = 0.15

var coyote_time_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# Habilidades de los niveles
var abilities: Array[AbilityBase] = []
var current_ability_index: int = 0

#Sprite del player
@onready var spriteA : AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	add_to_group("player")
	load_level_ability()

func load_level_ability():
	var level_ability_names = GameManager.get_level_abilities()

	for ability_name in level_ability_names:
		add_ability(ability_name)

func add_ability(ability_name: String):
	var ability_path = "res://scenes/player/abilities/" + ability_name + ".tscn"
	if not ResourceLoader.exists(ability_path):
		push_error("No hay habilidad: %s" % ability_name)
		return

	var ability_scene = load(ability_path) as PackedScene
	if not ability_scene:
		push_error("No se pudo cargar la escena de habilidad: %s" % ability_path)
		return

	var ability = ability_scene.instantiate() as AbilityBase
	if not ability:
		push_error("No se pudo instanciar la habilidad: %s" % ability_path)
		return
	
	add_child(ability)
	ability.putAbility(self)
	abilities.append(ability)
	

func _physics_process(delta: float):
	check_landing()
	handle_gravity(delta)
	update_timers(delta)
	handle_jump()
	handle_spin()
	handle_abilities(delta)
	handle_horizontal_movement(delta)
	update_animation()
	
	move_and_slide()

# Aplicar gravedad
func handle_gravity(delta: float):
	if is_on_floor():
		velocity.y = 0.0
		return
	
	var gravity_multiplier = spin_gravity_multiplier if is_spinning else 1.0
	velocity.y += gravity * gravity_multiplier * delta

	velocity.y = min(velocity.y, gravity * 2.0)

# Actualizar temporizadores
func update_timers(delta: float):
	coyote_time_timer = max(0.0, coyote_time_timer - delta)
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
	
	if spin_timer > 0.0:
		spin_timer -= delta
		if spin_timer <= 0.0:
			is_spinning = false
	
	# Coyote Time y estado cuando el payer esta en el suelo
	if is_on_floor():
		coyote_time_timer = coyote_time_duration
		can_spin = false
		is_spinning = false

func handle_jump():
	# Comprobar si hay que saltar
	var can_jump = is_on_floor() or coyote_time_timer > 0.0
	
	if jump_buffer_timer > 0.0 and can_jump and not is_anticipating and not jump_was_pressed:
		perform_jump()

func perform_jump():
	velocity.y = jump_velocity
	coyote_time_timer = 0.0
	jump_buffer_timer = 0.0
	can_spin = true
	jump_was_pressed = true

	is_anticipating = true
	get_tree().create_timer(0.08).timeout.connect(func():is_anticipating = false)

func check_landing():
	var is_in_air = not is_on_floor()
	
	if was_in_air and not is_in_air and not is_landing:
		is_landing = true
		get_tree().create_timer(0.15).timeout.connect(func():is_landing = false)

	was_in_air = is_in_air

# Giro en el aire (spin)
func handle_spin():
	var can_perform_spin = (
		Input.is_action_just_pressed("ui_accept") and
		not is_on_floor() and
		can_spin and
		not is_spinning and
		velocity.y > 0.0
	)
	
	if can_perform_spin:
		start_spin()

func start_spin():
	is_spinning = true
	can_spin = false
	spin_timer = spin_duration
	# Aqui poer los efectos de sonido o particulas al hacer el spin

# Movimiento horizontal
func handle_horizontal_movement(delta: float):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

#Cambiar animación
func update_animation():
	if velocity.x != 0:
		spriteA.flip_h = velocity.x > 0
	
	var new_animation = ""

	if is_landing:
		new_animation = "ground"
	elif is_anticipating:
		new_animation = "anticipation"
	elif is_on_floor():
		if abs(velocity.x) > 5:
			new_animation = "run"
		else:
			new_animation = "idle"
	else:
		if velocity.y < 0:
			new_animation = "jump"
		else:
			new_animation = "fall"
		
	if spriteA.animation != new_animation:
		spriteA.play(new_animation)
	

# Gestión de habilidades
func handle_abilities(delta: float):
	if abilities.is_empty():
		return
	
	var selected_ability = abilities[current_ability_index]
	selected_ability.physics_update(delta)

func cycle_ability():
	if abilities.size() <= 1:
		return

	current_ability_index = (current_ability_index + 1) % abilities.size()
	var ability_name = abilities[current_ability_index].name
	print("Habilidad seleccionada: %s" % ability_name)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if is_on_floor() or coyote_time_timer > 0.0:
			jump_buffer_timer = jump_buffer_duration
			jump_was_pressed = false

	if event.is_action_released("ui_accept"):
		jump_was_pressed = false
	
	if abilities.size() > 1 and event.is_action_pressed("cycle_ability"):
		cycle_ability()

	if not abilities.is_empty() and event.is_action_pressed("ability_action"):
		var selected_ability = abilities[current_ability_index]
		selected_ability.activate()

func get_current_ability() -> AbilityBase:
	if abilities.is_empty():
		return null
	return abilities[current_ability_index]

func has_ability(ability_name: String) -> bool:
	for ability in abilities:
		if ability.name == ability_name:
			return true
	return false

func collect_item(collectible: Collectible):
	var collectible_id = collectible.collectible_id

	if PlayerData.is_collectible_collected(GameManager.current_level, collectible_id):
		return

	PlayerData.add_collectible(GameManager.current_level, collectible_id)
	print("Coleccionable recogido: %s" % collectible_id)

	# Llamar al método collect() dl coleccionable para que se destruya
	if collectible.has_method("collect"):
		collectible.collect()

	#if not collectible.has("collectible_id"):
	#	push_error("El objeto coleccionable no tiene collectible_id")
	#	return

	#var collectible_id = collectible.get("collectible_id")
	#if collectible_id == null:
	#	push_error("collectible_id es null")
	#	return
