extends CanvasLayer

@onready var big_coin_label = $VBoxContainer/BigCoinLabel
@onready var coin_label = $VBoxContainer/CoinLabel

#big coins
var current_big_coins: int = 0
var total_big_coins: int = 0

#coins
var current_coins: int = 0
var total_coins: int = 0 

func _ready():
	add_to_group("hud")
	# Esperar pa que el nivel cargue todos los nodos
	await get_tree().process_frame

	# Conectar a todos los coleccionables
	connect_to_collectibles()

	# Actualizar display
	update_big_coin_display()

func connect_to_collectibles():
	var collectibles = get_tree().get_nodes_in_group("collectibles")
	total_big_coins = 0
	for collectible in collectibles:
		if collectible.has_signal("collected"):
			if collectible is Coin:
				collectible.collected.connect(_on_coin_collected)
			else:
				collectible.collected.connect(_on_big_coin_collected)
				total_big_coins += 1
	update_big_coin_display()

func _on_big_coin_collected(_collectible):
	current_big_coins += 1
	update_big_coin_display()
	print("Moneda recogida! Total: ", current_big_coins, "/", total_big_coins)

func _on_coin_collected(_coin):
	current_coins += 1
	update_coin_display()

func update_big_coin_display():
	big_coin_label.text = "Monedas Grandes: %d/%d" % [current_big_coins, total_big_coins]

func update_coin_display():
	coin_label.text = "Monedas x %d" % current_coins
