extends Sprite2D

signal character_stopped
signal character_exited

@export var enter_duration := 1
@export var bob_distance := 5.0
@export var bob_speed := 1.5

var target_position: Vector2
var bob_time := 0.0
var has_arrived := false

func _ready() -> void:
	# Start invisible / empty
	texture = null
	
	# Save the position you placed the sprite in the editor
	target_position = position
	
	# Move sprite off-screen to the left
	position.x = -get_viewport_rect().size.x

func _process(delta: float) -> void:
	# Bobbing motion (only after arrival)
	if position == target_position:
		bob_time += delta * bob_speed
		position.y = target_position.y + sin(bob_time) * bob_distance

func _on_gameplay_scene_1_new_character(characterTexture: Texture2D) -> void:
	texture = characterTexture
	
	# Reset position in case character changes
	position.x = -get_viewport_rect().size.x
	position.y = target_position.y
	
	# Tween movement to target position
	var tween := create_tween()
	tween.tween_property(
		self,
		"position",
		target_position,
		enter_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_enter_finished)

func _on_enter_finished() -> void:
	has_arrived = true
	print("enter finished")
	character_stopped.emit()


func _on_text_bubble_text_bye_message_done() -> void:
	# Stop bobbing
	has_arrived = false
	
	# Create tween to move character off-screen to the right
	var tween := create_tween()
	var viewport_width = get_viewport_rect().size.x
	var target_exit_position = Vector2(viewport_width + texture.get_width(), position.y)
	
	tween.tween_property(
		self,
		"position",
		target_exit_position,
		enter_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	tween.finished.connect(_on_exit_finished)
	
func _on_exit_finished() -> void:
	print("exit finished")
	character_exited.emit()
	


func _on_bye_button_pressed() -> void:
	has_arrived = false
	
	var tween := create_tween()
	var viewport_width = get_viewport_rect().size.x
	var target_exit_position = Vector2(
		viewport_width + texture.get_width(),
		position.y
	)
	
	tween.tween_property(
		self,
		"position",
		target_exit_position,
		enter_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	tween.finished.connect(_on_exit_finished)
