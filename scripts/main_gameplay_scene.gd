extends Control

var gamestate:String=""

var CharacterDB:Array[Texture2D]
var ProblemDB:Array[Problem]
signal newProblem(problem:Problem)
signal newCharacter(characterTexture:Texture2D)
signal graded_solution
var currentCharacter:Texture2D = null
var currentProblem = null
const problems_per_day := 5
var day_scene_path = "res://scenes/Day.tscn"

var shop_scene = preload("res://scenes/shop/Shop.tscn")

var score:int = 0 
@onready var music_player: AudioStreamPlayer = $MusicPlayer

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
			var clean_name = file_name.replace(".remap", "").replace(".import", "")
			if clean_name.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp"]:
				var full_path = dirPath + clean_name
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
				var clean_name = file_name.replace(".remap", "").replace(".import", "")
				if clean_name.get_extension().to_lower() == 'tres':
					var full_path = subdirpath + clean_name
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
	if GameInfo.problems_solved_today==GameInfo.problem_no_to_spawn_minigame:
		currentProblem= MinigameProblem.new()
		newProblem.emit(currentProblem)
		return
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
	AchievementsManager.new_achievement_unlocked.connect(_on_new_achievement_unlocked)
	music_player.stream.loop = true
	music_player.play()
	initCharacterDB()
	initProblemDB()
	GameInfo.set_minigame_problem_no(randi_range(0,problems_per_day-1))
	pickCharacter()
	pickProblem()
	

#---------------Grading Selections and advancing to next case-------------------


func gradeSolution(solutions:Array[String])->void:
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
	if newScoreDelta == solutions.size()*5:
		AchievementsManager.increment_num_perfect_solves()
	graded_solution.emit()
	

	
func _on_customer_sprite_character_exited() -> void:
	pickCharacter()         
	pickProblem()

func _on_email_node_submit_selection(solutions: Array[String]) -> void:
	gradeSolution(solutions)
	AchievementsManager.increment_email_problems_solved()

func _on_messages_node_submit_selection(solutions: Array[String]) -> void:
	gradeSolution(solutions)
	AchievementsManager.increment_messages_problems_solved()

func _on_real_life_node_submit_selection(solutions: Array[String]) -> void:
	gradeSolution(solutions)
	AchievementsManager.increment_real_life_problems_solved()


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
	var dir_path = "res://game_data/menu/"
	var target_file = ""
	
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Look for any file containing ".md" 
			# This catches "manual.md", "manual.md.import", etc.
			if not dir.current_is_dir() and file_name.contains(".md"):
				# Strip .import or .remap so FileAccess/load can read it correctly
				target_file = dir_path + file_name.replace(".import", "").replace(".remap", "")
				break # Stop at the first one found
			file_name = dir.get_next()
	
	if target_file == "":
		push_error("No .md file found in " + dir_path)
		return

	# Now use your existing logic with the dynamic path
	var md = load_markdown(target_file)
	var bb = md_to_bbcode(md)
	
	$ManualPopupCanvasLayer.visible = true
	$ManualPopupCanvasLayer/BackgroundButton/MenuBackgroundTR/ManualLabel.text = "Menu"
	$ManualPopupCanvasLayer/BackgroundButton/MenuBackgroundTR/ScrollContainer/VScrollBar/RichTextLabel.text = bb
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
	GameInfo.increment_problems_solved()
	print(GameInfo.problems_solved_today)
	print("Problems solved today ", GameInfo.problems_solved_today)
	if GameInfo.problems_solved_today >= problems_per_day:
		GameInfo.reset_problems_solved()
		Transition.transition_to(day_scene_path)
		return


func _on_checkout_button_show_problem() -> void:
	if currentProblem is not MinigameProblem:
		return
	var minigame_scene := load("res://scenes/minigame/MiniGame.tscn")
	music_player.stream_paused = true
	var minigame = minigame_scene.instantiate()
	minigame.name = "MinigameInstance"
	minigame.MinigameOver.connect(_on_minigame_finished)
	# Adding it here (to the root) makes it start at the top-left of the screen
	add_child(minigame)
	
func _on_minigame_finished(minigame_score:int):
	score+=minigame_score
	music_player.stream_paused = false
	graded_solution.emit()
	
func _on_new_achievement_unlocked(accessory: AccessoryData):
	var achievement_notification_scene := load("res://scenes/notifications/AchievementUnlockedScene.tscn")
	var achievement_notif: Node = achievement_notification_scene.instantiate()
	achievement_notif.name = "AchievementNotificationInstance"
	add_child(achievement_notif)
	achievement_notif.initialize(accessory)
	# Adding it here (to the root) makes it start at the top-left of the screen
	
