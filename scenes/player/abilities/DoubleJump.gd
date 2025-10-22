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

func has_used_double_jump() -> bool:
	return has_double_jumped

func is_double_jump_available() -> bool:
	return not has_double_jumped and not player.is_on_floor()