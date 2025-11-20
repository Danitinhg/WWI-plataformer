extends CanvasLayer

@onready var big_coin_label = $MarginContainer/BigCoinLabel

var current_big_coins: int = 0
var total_big_coins: int = 3

func _ready():
	update_big_coin_display()

func update_big_coin_display():
	big_coin_label.text = "Monedas Grandes: %d/%d" % [current_big_coins, total_big_coins]

func add_big_coin():
	current_big_coins +=1
	update_big_coin_display()
	print("Moneda Grande regida | Total: ", current_big_coins)
