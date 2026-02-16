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
	visible = true


func _on_bye_button_pressed() -> void:
	visible = false


func _on_checkout_button_show_problem() -> void:
	visible=false


func _on_gameplay_scene_1_graded_solution() -> void:
	visible=true
