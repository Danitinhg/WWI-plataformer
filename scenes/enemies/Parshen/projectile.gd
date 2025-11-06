extends Area2D

const SPEED = 300
var direction = Vector2.RIGHT

#func _ready():
    #body_entered.connect(_on_body_entered)
    
    #var screen_notifier = $VisibleOnScreenNotifier2D
    #if screen_notifier:
        #screen_notifier.screen_exited.connect(queue_free)

func _physics_process(delta):
    global_position += direction * SPEED * delta

func _on_body_entered(body):
    if body.is_in_group("player"):
        print("¡Jugador golpeado!")

    queue_free()