extends Control

var gamestate:String=""

var CharacterDB:Array[Texture2D]
var ProblemDB:Array[Problem]
signal newProblem(problem:Problem)
signal newCharacter(characterTexture:Texture2D)
signal graded_solution
signal score_into_money
var currentCharacter:Texture2D = null
var currentProblem:Problem = null
var number_problems_solved := 0
const problems_per_day := 2
var day_scene_path = "res://scenes/Day.tscn"

var shop_scene = preload("res://scenes/shop/Shop.tscn")

@onready var score:int = 0 
@onready var accessory_container = $Accessories # The parent node of all your sprites


#----------------- Initialising databases -----------------
func initCharacterDB():
	var dirPath:String = "res://assets/characters/"
	var dir := DirAccess.open(dirPath)
	if dir == null:
		push_error("Could not open folder: " + dirPath)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir():
			if file_name.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp"]:
				var full_path = dirPath + file_name
				var tex := load(full_path)
				if tex:
					CharacterDB.append(tex)
		file_name = dir.get_next()

	dir.list_dir_end()


func initProblemDB():
	var dirPath:String = "res://game_data/problems/"
	var dir := DirAccess.open(dirPath)
	if dir == null:
		push_error("Could not open folder: " + dirPath)
		return
	
	var subdirectories = dir.get_directories()
	
	for subdirectory in subdirectories:
		var subdirpath = dirPath+subdirectory+"/"
		var subdir := DirAccess.open(subdirpath)
		subdir.list_dir_begin()
		var file_name := subdir.get_next()
		while file_name != "":
			if not subdir.current_is_dir():
				if file_name.get_extension().to_lower() == 'tres':
					var full_path = subdirpath + file_name
					var problem := ResourceLoader.load(full_path)
					if problem:
						ProblemDB.append(problem)
			file_name = subdir.get_next()
		subdir.list_dir_end()



func pickCharacter():
	var newChar
	if not currentCharacter:
		newChar = CharacterDB.pick_random()
	else:
		newChar=CharacterDB.pick_random()
		while newChar == currentCharacter:
			newChar=CharacterDB.pick_random()
	currentCharacter = newChar
	newCharacter.emit(currentCharacter)


func pickProblem() -> void:
	var newProb
	if not currentProblem:
		newProb = ProblemDB.pick_random()
	else:
		newProb=ProblemDB.pick_random()
		while newProb == currentProblem:
			newProb=ProblemDB.pick_random()
	currentProblem = newProb
	newProblem.emit(currentProblem)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#update_accessory_visibility()
	initCharacterDB()
	initProblemDB()
	pickCharacter()
	pickProblem()
#	reparent(get_tree().root)


#func update_accessory_visibility():
	## Loop through every sprite inside the Accessories container
	#for sprite in accessory_container.get_children():
		## Check if the node's name is in the equipped_items array
		#if sprite.name in ShopGameData.equipped_items:
			#sprite.show() # or sprite.visible = true
		#else:
			#sprite.hide() # or sprite.visible = false


#---------------Grading Selections and advancing to next case-------------------


func gradeSolution(solutions:Array[String])->void:
	number_problems_solved +=1
	var correctChoices = currentProblem.get_correct_choices()
	var newScoreDelta=0
	for solution in solutions:
		if solution in correctChoices:
			newScoreDelta+=5
		else:
			newScoreDelta-=2
	
	for correctChoice in correctChoices:
		if correctChoice not in solutions:
			newScoreDelta-=2 
	
	if len(correctChoices) == 0:
		newScoreDelta+=5
	
	score+=newScoreDelta
	if newScoreDelta > 0:
		ShopGameData.add_money(newScoreDelta*10)
	print("new Score:",score)
	

	
func _on_customer_sprite_character_exited() -> void:
	pickCharacter()
	pickProblem()

func _on_email_node_submit_selection(solutions: Array[String]) -> void:
	gradeSolution(solutions)
	graded_solution.emit()

func _on_messages_node_submit_selection(solutions: Array[String]) -> void:
	gradeSolution(solutions)
	graded_solution.emit()

func _on_real_life_node_submit_selection(solutions: Array[String]) -> void:
	gradeSolution(solutions)
	graded_solution.emit()


#----------------------Manual popups controls--------------------------


func md_to_bbcode(md: String) -> String:
	var bb := md
	var regex := RegEx.new()

	# 1. Bold (Handle **text** or __text__)
	regex.compile(r"(\*\*|__)(.*?)\1")
	bb = regex.sub(bb, "[b]$2[/b]", true)

	# 2. Italics (Handle *text* or _text_)
	# Note: Do this AFTER bold to avoid conflicts
	regex.compile(r"(\*|_)(.*?)\1")
	bb = regex.sub(bb, "[i]$2[/i]", true)

	# 3. Headers (Replace # Header with [font_size] tags)
	# Using multiline search to find # at the start of any line
	regex.compile(r"(?m)^### (.*)")
	bb = regex.sub(bb, "[b][font_size=14]$1[/font_size][/b]", true)
	
	regex.compile(r"(?m)^## (.*)")
	bb = regex.sub(bb, "[b][font_size=18]$1[/font_size][/b]", true)
	
	regex.compile(r"(?m)^# (.*)")
	bb = regex.sub(bb, "[b][font_size=22]$1[/font_size][/b]", true)

	return bb
	
	
func load_markdown(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	return file.get_as_text()
	
func _on_open_manual_button():
	var path=""
	var title := ""
	if currentProblem is EmailProblem:
		title = "Emails menu"
		path = "res://game_data/menu/email_menu.md"
	elif currentProblem is RealLifeProblem:
		title = "Real Life menu"
		path = "res://game_data/menu/real_life_menu.md"
	elif currentProblem is MessagesProblem:
			title = "Messages menu"
			path = "res://game_data/menu/messages_menu.md"
	
	var md = load_markdown(path)
	var bb = md_to_bbcode(md)
	$ManualPopupCanvasLayer.visible = true
	$ManualPopupCanvasLayer/BackgroundButton/MenuBackgroundTR/ManualLabel.text = title
	$ManualPopupCanvasLayer/BackgroundButton/MenuBackgroundTR/ScrollContainer/VScrollBar/RichTextLabel.text = bb
	#Sakav ovde da dodam avtomatsko menuvanje na fokusot na menito, no trebashe ko ushte edna skripta (: 

func _on_background_button_button_down() -> void:
	var canvas = $ManualPopupCanvasLayer
	canvas.visible = false



func _on_open_shop_button_pressed() -> void:
	# Check if shop is already open
	if has_node("ShopInstance"):
		return
	# Instantiate and name it
	var shop = shop_scene.instantiate()
	shop.name = "ShopInstance"
	# Adding it here (to the root) makes it start at the top-left of the screen
	add_child(shop)
	


func _on_bye_button_pressed() -> void:
	if number_problems_solved == problems_per_day:
		number_problems_solved = 0
		Transition.transition_to(day_scene_path)
		return
