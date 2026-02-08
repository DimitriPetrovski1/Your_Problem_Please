extends Label

@export var characters_per_second := 30.0

var _elapsed := 0.0
var _is_typing := false
var currentProblem = ""

func _ready():
	visible_characters = 0

func _process(delta):
	if not _is_typing:
		return

	_elapsed += delta
	visible_characters = int(_elapsed * characters_per_second)

	if visible_characters >= text.length():
		visible_characters = text.length()
		_is_typing = false

func start_typing(new_text: String):
	text = new_text
	visible_characters = 0
	_elapsed = 0.0
	_is_typing = true

func _on_gameplay_scene_1_new_problem(problem: Problem) -> void:
	#start_typing(problem.get_short_description())
	currentProblem = problem.get_short_description()
	print(currentProblem)


func _on_texture_button_visibility_changed() -> void:
	pass # Replace with function body.


func _on_customer_sprite_character_stopped() -> void:
	print('stopped moving')
	start_typing(currentProblem)
