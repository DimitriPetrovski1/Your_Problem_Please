extends Node2D
signal close

@onready var achievementTR = $BackgroundBackButton/TextureRect/TextureRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(accessory_data: AccessoryData):
	achievementTR.texture = accessory_data.texture


func _on_button_pressed() -> void:
	queue_free()


func _on_background_back_button_pressed() -> void:
	queue_free()
