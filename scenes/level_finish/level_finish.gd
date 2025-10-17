# Area2D invisible para que se detecte cuando el jugador llega al final del nievl.
extends Collectible

func collect():
	super.collect()

	# gmanager se entera de que se completo el nivel
	GameManager.complete_level()

	# Temporizador pa no volver al mapa de seguido
	var timer = get_tree().create_timer(1.5)
	timer.timeout.connect(on_level_end_timer_timeout)

func on_level_end_timer_timeout():
	# Vuelve al mapa
	GameManager.return_to_level_selector()
