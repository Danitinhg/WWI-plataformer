extends CanvasLayer

@onready var big_coin_label = $MarginContainer/BigCoinLabel

var current_big_coins: int = 0
var total_big_coins: int = 0

func _ready():
	# Esperar pa que el nivel cargue todos los nodos
	await get_tree().process_frame

	# Contar cuántas big_coins hay en el nivel
	count_total_coins()

	# Conectar a todos los coleccionables
	connect_to_collectibles()

	# Actualizar display
	update_big_coin_display()

func count_total_coins():
	var collectibles = get_tree().get_nodes_in_group("collectibles")
	total_big_coins = collectibles.size()
	print("Total de monedas en el nivel: ", total_big_coins)

func connect_to_collectibles():
	var collectibles = get_tree().get_nodes_in_group("collectibles")
	for collectible in collectibles:
		if collectible.has_signal("collected"):
			collectible.collected.connect(_on_coin_collected)
			print("Conectado a coleccionable: ", collectible.name)

func _on_coin_collected(_collectible):
	current_big_coins += 1
	update_big_coin_display()
	print("Moneda recogida! Total: ", current_big_coins, "/", total_big_coins)

func update_big_coin_display():
	big_coin_label.text = "Monedas Grandes: %d/%d" % [current_big_coins, total_big_coins]
