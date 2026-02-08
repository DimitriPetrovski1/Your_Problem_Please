extends Control

var pop_tween: Tween

func _ready() -> void:
	visible = false
	scale = Vector2.ZERO
	pivot_offset = size / 2


func _on_customer_sprite_character_stopped() -> void:
	visible = true
	scale = Vector2.ZERO
	
	if pop_tween:
		pop_tween.kill()
	
	pop_tween = create_tween()
	pop_tween.set_trans(Tween.TRANS_BACK)
	pop_tween.set_ease(Tween.EASE_OUT)
	
	pop_tween.tween_property(self, "scale", Vector2.ONE, 0.25)
