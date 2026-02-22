extends Control

@onready var music_player = $MusicPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_player.play()

func _on_start_pressed() -> void:
	print("Start pressed")
	Transition.transition_to("res://scenes/Day.tscn")

func _on_settings_pressed() -> void:
	print("Settings pressed")

func _on_exit_pressed() -> void:
	get_tree().quit()
	
