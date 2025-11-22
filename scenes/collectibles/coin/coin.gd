extends Collectible
class_name Coin

func _ready():
	super._ready()

	if sprite:
		sprite.play("idle")
