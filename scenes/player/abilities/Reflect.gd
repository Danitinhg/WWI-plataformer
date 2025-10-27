extends AbilityBase

@export var reflect_duration: float = 0.5
@export var cooldown: float = 1.5
@export var shield_offset: float = 40.0

var cooldown_timer: float = 0.0
var reflect_timer: float = 0.0
var is_active: bool = false

@onready var reflect_area: Area2D = $ReflectArea
@onready var collision_shape: CollisionShape2D = $ReflectArea/CollisionShape2D
@onready var shield_visual: Polygon2D = $ShieldVisual

func _ready() -> void:
	if not reflect_area or not collision_shape or not shield_visual:
		push_error("Reflect: Faltan nodos en la escena (ReflectArea, CollisionShape2D, ShieldVisual)")
		return
	deactivate_shield()

func physics_update(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	if reflect_timer > 0:
		reflect_timer -= delta
	else:
		if is_active:
			deactivate_shield()
	
	# Si el escudo ta activo, seguir al jugador
	if is_active:
		_update_shield_position()

func activate() -> void:
	# No pone el escudo si ya esta activo o en cooldown
	if is_active or cooldown_timer > 0:
		return
	
	if not player:
		push_error("Reflect: Player no asignado")
		return
	
	# Activa el escudo
	is_active = true
	reflect_timer = reflect_duration
	cooldown_timer = cooldown
	
	shield_visual.visible = true
	collision_shape.disabled = false
	
	# Posicionar y orientar el escudo
	_update_shield_position()

func deactivate_shield() -> void:
	is_active = false
	shield_visual.visible = false
	collision_shape.disabled = true

func _update_shield_position() -> void:
	"""Posiciona el escudo frente al jugador según su dirección"""
	if not player.has_node("Sprite2D"):
		push_error("Reflect: Player no tiene nodo Sprite2D")
		return

	var sprite = player.get_node("Sprite2D")
	var is_facing_left = sprite.flip_h
	
	# Poner rotación de la esfera
	if is_facing_left:
		rotation = deg_to_rad(180)
		global_position = player.global_position + Vector2(-shield_offset, 0)
	else:
		rotation = 0.0
		global_position = player.global_position + Vector2(shield_offset, 0)

func _on_reflect_area_body_entered(body: Node2D):
	"""Detectar y reflejar proyectiles"""
	if not body.is_in_group("enemy_projectiles"):
		return

	if not "velocity" in body:
		push_warning("Reflect: Proyectil %s no tiene propiedad velocity" % body.name)
		return
	
	if not is_active:
		return
	
	var shield_normal = Vector2.RIGHT.rotated(global_rotation)
	
	body.velocity = body.velocity.bounce(shield_normal)
	body.owner = player
	_on_projectile_reflected(body)


func _on_projectile_reflected(projectile: Node2D) -> void:
	"""Se llama cuando un proyectil es reflejado - agregar efectos aquí"""
	#Agregar efectos visuales (partículas, destello)
	#Agregar efectos de sonido
	pass