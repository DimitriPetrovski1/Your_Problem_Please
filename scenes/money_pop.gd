extends Sprite2D

func _ready() -> void:
	modulate.a = 1.0
	scale = Vector2(0.5, 0.5)
	
	var tween = create_tween().set_parallel(true)
	
	# THE FIX: Move relative to current position (position.y - 100)
	tween.tween_property(self, "position:y", position.y - 100, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 1.5)
	
	# Quick scale pop
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	
	# Kill the sprite when finished
	tween.chain().tween_callback(queue_free)
