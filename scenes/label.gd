extends Label

# Preload the effect so it's ready to go
@export var money_effect_scene: PackedScene = preload("res://scenes/MoneyPop.tscn")

func _ready() -> void:
	text = "$" + str(ShopGameData.money)
	ShopGameData.money_changed.connect(_on_money_changed)

func _on_money_changed(new_amount):
	# Update the text
	text = "$" + str(new_amount)
	
	# Play the animation
	_spawn_money_animation()

func _spawn_money_animation():
	if money_effect_scene:
		var effect = money_effect_scene.instantiate()
		
		# Add it to the label's parent (so it doesn't move with the label if the UI shifts)
		# Or add it to a dedicated "Effects" node in your main scene
		get_parent().add_child(effect)
		
		# Center it on the label
		effect.global_position = global_position
