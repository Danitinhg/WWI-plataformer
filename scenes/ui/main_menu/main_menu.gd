extends Control

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/level_selector/level_selector.tscn")

func _on_test_level_button_pressed():
	GameManager.load_level(-1)

func _on_quit_button_pressed():
	get_tree().quit()
