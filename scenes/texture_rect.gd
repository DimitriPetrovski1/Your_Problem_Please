extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_customer_sprite_character_stopped() -> void:
	visible = true
	

func _on_gameplay_scene_1_submited_answers() -> void:
	visible = false
