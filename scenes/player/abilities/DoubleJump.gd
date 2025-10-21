extends AbilityBase

@export var double_jump_velocity: float = -350.0
var has_double_jumped: bool = false

func process(_delta: float):
	if player.is_on_floor():
		has_double_jumped = false

func activate():
	if not player.is_on_floor() and not has_double_jumped:
		player.velocity.y = double_jump_velocity
		has_double_jumped = true
		# efecto visual o particulas abajo