extends Node2D

var camera: Camera2D
@export var x_offset: float = -250.0
@onready var water = $AnimatedSprite2D

func _ready():
    water.play("idle")
    #Esperar a que todo cargue
    await get_tree().process_frame
      
    #Buscar la cámara del player
    var player = get_tree().get_first_node_in_group("player")
    if player:
        camera = player.get_node_or_null("Camera2D")

    if not camera:
        print("ERROR: No se encontró la cámara del player")
    else:
        print("Cámara encontrada!")

func _process(_delta):
    if camera:
        #TODA la escena sigue la X de la cámara
        global_position.x = camera.get_screen_center_position().x + x_offset
        #Y fija (ajusta según donde quieras el background)
        global_position.y = 0  # Ajusta este valor