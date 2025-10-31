extends AbilityBase

@export var dash_speed: float = 750.0
@export var dash_duration: float = 0.15
@export var cooldown: float = 0.8

var cooldown_timer: float = 0.0
var dash_timer: float = 0.0

func physics_update(delta: float) -> bool:
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	if dash_timer > 0:
		dash_timer -= delta
		
		# Con el dahs activo anulamos velocidad del jugador
		var dash_direction = 1 if player.get_node("AnimatedSprite2D").flip_h else -1
		player.velocity.x = dash_direction * dash_speed
		player.velocity.y = 0  # Anulamos la gravedad del payer
		
		if dash_timer <= 0:
			player.velocity.x = 0
		
		return true #Dash activo
	
	return false #Dash no activo

func activate():
	if cooldown_timer <= 0:
		dash_timer = dash_duration
		cooldown_timer = cooldown