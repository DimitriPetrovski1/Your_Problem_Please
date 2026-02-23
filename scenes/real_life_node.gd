extends Control

signal submitSelection(solutions:Array[String])

@onready var checkboxes:Array[CheckButton]=[]
@onready var currProblem:Problem = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	visible = false


func buildSelectionSection(problem:RealLifeProblem):
	checkboxes = []
	var RealLifeSelectionContainer =  $VBoxContainer/RealLifeLelectionPanel/RealLifeSelectionContainer
	for child in RealLifeSelectionContainer.get_children():
		child.queue_free()
	for option in problem.get_possible_choices():
		var cb := CheckButton.new()
		cb.text = option
		cb.add_theme_color_override("font_color", Color.BLACK)
		cb.add_theme_color_override("font_focus_color", Color.BLACK)
		cb.add_theme_color_override("font_hover_color", Color.WHITE) 
		cb.add_theme_color_override("font_pressed_color", Color.WHITE)
		cb.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cb.add_theme_icon_override("checked",ResourceLoader.load("res://assets/UI/Checkmark Selected.png"))
		cb.add_theme_icon_override("unchecked",ResourceLoader.load("res://assets/UI/Checkmark Unselected.png"))
		RealLifeSelectionContainer.add_child(cb)
		checkboxes.append(cb)

func _on_gameplay_scene_1_new_problem(problem: Problem) -> void:
	currProblem = problem
	visible = false
	if problem is RealLifeProblem:
		$VBoxContainer/RealLifeDisplayPanel/RealLifeTextLabel.text=problem.description
		buildSelectionSection(problem)


func _on_real_life_submit_solution_button_pressed() -> void:
	var selections:Array[String] = []
	
	for cb in checkboxes:
		if cb.button_pressed:
			selections.append(cb.text)
			
	
	visible = false
	submitSelection.emit(selections)

func _on_checkout_button_show_problem() -> void:
	if currProblem is RealLifeProblem:
		visible = true
		print("Problem")

func _on_open_problem_button_pressed() -> void:
	if currProblem is RealLifeProblem:
		visible = (visible != true)
