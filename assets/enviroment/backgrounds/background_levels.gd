extends Node2D

var camera: Camera2D
var player: CharacterBody2D

@export var x_offset: float = -250.0
@onready var water = $AnimatedSprite2D

@export_group("Movimiento progresivo del agua")
@export var start_x: float = 0.0
@export var end_x: float = 8000.0
@export var water_start_pos: float = 600.0
@export var water_end_pos: float = -400.0

func _ready():
    #inica la animacion del agua
    if water:
        water.play("idle")

    await get_tree().process_frame

    player = get_tree().get_first_node_in_group("player")
    if not player:
        print("No se encontró el player")
        return

    if player:
        camera = player.get_node_or_null("Camera2D")

    if not camera:
        print("No se encontró la cámara del player")

func _process(_delta):
    if not camera or not player:
        return

    #back sigue a camara
    global_position.x = camera.get_screen_center_position().x + x_offset
    global_position.y = 0

    var player_x = player.global_position.x
    var progress = clamp((player_x - start_x) / (end_x - start_x), 0.0, 1.0)

    #mueve el agua segun el porgreso
    if water:
        water.position.x = lerp(water_start_pos, water_end_pos, progress)