extends Control

signal submitSelection(solutions:Array[String])

@onready var checkboxes:Array[CheckButton]=[]
@onready var currProblem:Problem=null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


func buildSelectionSection(problem:MessagesProblem):
	checkboxes = []
	var MessagesSelectionContainer =  $VBoxContainer/MessagesSelectionPanel/MessagesSelectionContainer
	for child in MessagesSelectionContainer.get_children():
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
		MessagesSelectionContainer.add_child(cb)
		checkboxes.append(cb)

func _on_gameplay_scene_1_new_problem(problem: Problem) -> void:
	visible = false
	currProblem=problem
	if problem is MessagesProblem:
		var VBC = $VBoxContainer/MessagesDisplayPanel/ScrollContainer/VerticallScrollableContainer/VBoxContainer
		for child in VBC.get_children():
			child.queue_free()
		for message in problem.messages:
			#sig zaborajv da smenam nesh ovde
			var pc = PanelContainer.new()
			var textBubble = NinePatchRect.new()
			textBubble.texture=load("res://assets/UI/TextBubble.png")
			var mc = MarginContainer.new()
			
			mc.add_theme_constant_override("margin_left", 15)
			mc.add_theme_constant_override("margin_top", 15)
			mc.add_theme_constant_override("margin_right", 10)
			mc.add_theme_constant_override("margin_bottom", 35)
			var label = Label.new()
			label.text = message
			label.add_theme_font_size_override("name",20)
			label.add_theme_color_override("font_color",Color.BLACK)
			pc.size_flags_vertical = Control.SIZE_EXPAND_FILL
			pc.add_child(textBubble)
			pc.add_child(mc)
			mc.add_child(label)
			pc.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
			VBC.add_child(pc)
			buildSelectionSection(problem)


func _on_messages_submit_solution_button_pressed() -> void:
	var selections:Array[String] = []
	
	for cb in checkboxes:
		if cb.button_pressed:
			selections.append(cb.text)
	
	
	visible = false
	submitSelection.emit(selections)
	currProblem = null

func _on_checkout_button_show_problem() -> void:
	if currProblem is MessagesProblem:
		visible = true
		print("Problem")


func _on_open_problem_button_pressed() -> void:
	if currProblem is MessagesProblem:
		visible = (visible != true)
