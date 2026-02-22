extends Node
const SAVE_PATH = "user://achievements.json"
const PATH_TO_ACCESSORIES = "res://scenes/shop/accessories/"

signal new_achievement_unlocked(accessory: AccessoryData)

var all_achievements: Array[AccessoryData] = []
var earned_achievements:Array[AccessoryData] = []

var real_life_problems_solved := 0
var email_problems_solved := 0
var messages_problems_solved := 0
var num_perfect_solves := 0
var num_bought_items:= 0 

func check_for_new_achievements():
	for achievement in all_achievements:
		if check_achievement_status(achievement) and achievement not in earned_achievements:
			earned_achievements.append(achievement)
			ShopGameData.owned_items.append(achievement.id)
			ShopGameData.save_game()
			new_achievement_unlocked.emit(achievement)
	save_game()
	
func increment_real_life_problems_solved():
	real_life_problems_solved+=1
	check_for_new_achievements()

func increment_email_problems_solved():
	email_problems_solved+=1
	check_for_new_achievements()
	
func increment_messages_problems_solved():
	messages_problems_solved+=1
	check_for_new_achievements()
	
func increment_num_perfect_solves():
	num_perfect_solves+=1
	check_for_new_achievements()

func set_num_bought_items(nbi:int):
	num_bought_items=nbi
	check_for_new_achievements()
	



# Map the "id" from the .tres file directly to a function
@onready var check_functions := {
	"0": func(): return real_life_problems_solved >= 5,
	"1": func(): return real_life_problems_solved >= 10,
	"2": func(): return real_life_problems_solved >= 20,
	"3": func(): return email_problems_solved >= 5,
	"4": func(): return real_life_problems_solved >= 10,
	"5": func(): return real_life_problems_solved >= 20,
	"6": func(): return messages_problems_solved >= 5,
	"7": func(): return messages_problems_solved >= 10,
	"8": func(): return messages_problems_solved >= 20,
	"9": func(): return num_perfect_solves >= 50,
	"10": func(): return num_bought_items >= 5,
}

func _ready():
	load_and_filter_accessories()
	load_game()
	

func load_and_filter_accessories():
	var dir = DirAccess.open(PATH_TO_ACCESSORIES)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"):
				var res: AccessoryData = load(PATH_TO_ACCESSORIES + file_name) as AccessoryData
				# Only keep it if it's NOT purchasable (an achievement)
				if res and not res.get("purchasable"):
					all_achievements.append(res)
			file_name = dir.get_next()

func check_achievement_status(accessory: AccessoryData) -> bool:
	# Look up the function using the ID from the resource
	if check_functions.has(accessory.id):
		return check_functions[accessory.id].call()
	return false


func save_game():
	# We save IDs because we can't save Resource Objects directly to JSON
	var earned_ids = []
	for acc in earned_achievements:
		earned_ids.append(acc.id)

	var data := {
		"real_life_problems_solved": real_life_problems_solved,
		"email_problems_solved": email_problems_solved,
		"messages_problems_solved": messages_problems_solved,
		"num_perfect_solves": num_perfect_solves,
		"num_bought_items": num_bought_items,
		"earned_achievement_ids": earned_ids
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if json_data == null:
		printerr("AccessoryManager: Failed to parse save file.")
		return

	# Load standard variables (using .get() to prevent crashes if keys are missing)
	real_life_problems_solved = json_data.get("real_life_problems_solved", 0)
	email_problems_solved = json_data.get("email_problems_solved", 0)
	messages_problems_solved = json_data.get("messages_problems_solved", 0)
	num_perfect_solves = json_data.get("num_perfect_solves", 0)
	num_bought_items = json_data.get("num_bought_items", 0)

	# Restore the 'earned_achievements' list by matching IDs
	earned_achievements.clear()
	var earned_ids = json_data.get("earned_achievement_ids", [])
	for acc in all_achievements:
		if acc.id in earned_ids:
			earned_achievements.append(acc)