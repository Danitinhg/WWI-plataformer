extends Node

@export var dash_speed: float = 750.0
@export var dash_duration: float = 0.15
@export var cooldown: float = 0.8

var cooldown_timer: float = 0.0
var dash_timer: float = 0.0
var player: CharacterBody2D = null
var can_dash: bool = true
