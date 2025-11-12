extends CharacterBody2D

# Movimiento básico del player
@export_group("Movimiento")
@export var speed: float = 100.0
@export var acceleration: float = 250.0
@export var friction: float = 800.0
@export_group("Movimeinto aereo")
@export var air_acceleration: float = 500.0
@export var air_friction: float = 100.0
@export var air_turn_acceleration: float = 1200.0

const max_gravity_multiplier: float = 2.0
const anticipation_duration: float = 0.08
const landing_duration: float = 0.15

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
@export var spin_duration: float = 0.25
@export var spin_boost: float = -100.0
@export var spin_gravity_multiplier: float = 0.4
@export var spin_horizontal_boost: float = 1.1

var is_spinning: bool = false
var spin_timer: float = 0.0
var can_spin: bool = false
var spin_rotation: float = 0.0

# Coyote Time y Jump Buffer
@export_group("Controles Avanzados")
@export var coyote_time_duration: float = 0.15
@export var jump_buffer_duration: float = 0.15

var coyote_time_timer: float = 0.0
var jump_buffer_timer: float = 0.0

#Corner Correction
@export_group("Corner Correction")
@export var corner_correction_enabled: bool = true
@export var corner_correction_amount: int = 8

# Habilidades de los niveles
var abilities: Array[AbilityBase] = []
var current_ability_index: int = 0
var ability_in_control: bool = false

#Sistema de vida
@export_group("Sistema de vida")
@export var max_health: int = 3
@export var invincibility_duration: float = 1.5
@export var knockback_force: float = 300.0

var current_health: int = 3
var is_invincible: bool = false
var is_dead: bool = false

signal health_changed(new_health: int, max_health: int)
signal player_damaged(damage: int)
signal player_died

#Sprite del player
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

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
	handle_abilities(delta)
	handle_horizontal_movement(delta)
	attempt_corner_correction()
	update_animation()
	update_spin_visual(delta)
	move_and_slide()

# Aplicar gravedad
func handle_gravity(delta: float):
	if ability_in_control:
		return

	if is_on_floor():
		velocity.y = 0.0
		return

	var gravity_multiplier = spin_gravity_multiplier if is_spinning else 1.0
	velocity.y += gravity * gravity_multiplier * delta

	velocity.y = min(velocity.y, gravity * max_gravity_multiplier)

# Actualizar temporizadores
func update_timers(delta: float):
	coyote_time_timer = max(0.0, coyote_time_timer - delta)
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
	
	if spin_timer > 0.0:
		spin_timer -= delta
		if spin_timer <= 0.0:
			end_spin()
	
	# Coyote Time y estado cuando el payer esta en el suelo
	if is_on_floor():
		coyote_time_timer = coyote_time_duration
		can_spin = false
		if is_spinning:
			end_spin()

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
	get_tree().create_timer(anticipation_duration).timeout.connect(func():is_anticipating = false)

func check_landing():
	var is_in_air = not is_on_floor()
	
	if was_in_air and not is_in_air and not is_landing:
		is_landing = true
		get_tree().create_timer(landing_duration).timeout.connect(func():is_landing = false)

	was_in_air = is_in_air

func start_spin():
	is_spinning = true
	can_spin = false
	spin_timer = spin_duration
	spin_rotation = 0.0

	velocity.y = spin_boost

	if abs(velocity.x) > 10:
		velocity.x *= spin_horizontal_boost

	# Aqui poer los efectos de sonido o particulas al hacer el spin

func end_spin():
	is_spinning = false
	animated_sprite.scale.x = 1.0
	animated_sprite.rotation = 0.0

func update_spin_visual(delta: float):
	if not is_spinning:
		return

	var spin_speed = (PI * 1.0) / spin_duration
	spin_rotation += spin_speed * delta
	
	var effect_paper_mario = abs(cos(spin_rotation))
	animated_sprite.scale.x = lerp(0.1, 1.0, effect_paper_mario)

	if animated_sprite.flip_h:
		animated_sprite.scale.x = -abs(animated_sprite.scale.x)

# Movimiento horizontal
func handle_horizontal_movement(delta: float):
	if ability_in_control:
		return

	var direction = Input.get_axis("ui_left", "ui_right")

	var accel: float = acceleration
	var fric: float = friction

	if not is_on_floor():
		if direction != 0 and velocity.x != 0 and sign(direction) != sign(velocity.x):
			accel = air_turn_acceleration
		else:
			accel = air_acceleration

		fric = air_friction

	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)

# Corner Correction
func attempt_corner_correction():
	if not corner_correction_enabled:
		return
	
	# Solo intentar corrección cuando está subiendo
	if velocity.y >= 0:
		return
	
	var dt = get_physics_process_delta_time()
	var motion = Vector2(0, velocity.y * dt)
	
	# Ver si hay colision verticalmente
	if test_move(global_transform, motion):
		for i in range(1, corner_correction_amount + 1):
			for direction in [-1.0, 1.0]:
				var offset = Vector2(i * direction, 0)
				if not test_move(global_transform.translated(offset), motion):
					# Aplicar la corrección
					global_position.x += i * direction

					if velocity.x * direction < 0:
						velocity.x = 0
					
					return

#Cambiar animación
func update_animation():
	if velocity.x != 0 and not ability_in_control and not is_spinning:
		animated_sprite.flip_h = velocity.x > 0
	
	var new_animation = ""
	var ability_animation = ""

	if not abilities.is_empty():
		ability_animation = abilities[current_ability_index].get_animation_name()

	if ability_animation != "":
		new_animation = ability_animation
	elif is_spinning:
		new_animation = "spin"
	elif is_landing:
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
		
	if animated_sprite.animation != new_animation:
		animated_sprite.play(new_animation)
	
# Gestión de habilidades
func handle_abilities(delta: float):
	if abilities.is_empty():
		ability_in_control = false
		return
	
	var selected_ability = abilities[current_ability_index]
	ability_in_control = selected_ability.physics_update(delta)

func cycle_ability():
	if abilities.size() <= 1:
		return

	current_ability_index = (current_ability_index + 1) % abilities.size()
	var ability_name = abilities[current_ability_index].name
	print("Habilidad seleccionada: %s" % ability_name)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		var can_jump = is_on_floor() or coyote_time_timer > 0.0
		
		if can_jump:
			jump_buffer_timer = jump_buffer_duration
			jump_was_pressed = false
		elif can_spin and not is_on_floor() and not is_spinning and not ability_in_control:
			start_spin()
			
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

func get_facing_direction() -> int:
	return 1 if animated_sprite.flip_h else -1