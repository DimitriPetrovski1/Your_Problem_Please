extends Node

const SAVE_PATH := "user://game_info.json"
var day_count: int = 1
var problems_solved_today := 0
var problem_no_to_spawn_minigame = null

func _ready():
	load_game()

func increment_day():
	day_count+=1
	save_game()
#	money_changed.emit(money) # Tell everyone the money changed!
func increment_problems_solved():
	problems_solved_today+=1
	save_game()

func reset_problems_solved():
	problems_solved_today=0
	save_game()
func set_minigame_problem_no(pr:int):
	problem_no_to_spawn_minigame = pr
	save_game()


	
	
func save_game():
	var data := {
		"day_count": day_count,
		"problems_solved_today": problems_solved_today,
		"problem_no_to_spawn_minigame":problem_no_to_spawn_minigame,
		}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	var data = JSON.parse_string(json_string)
	
	if data == null:
		printerr("Failed to parse save file.")
		return
	

	# Simple variables (int, float, bool) work fine with '='
	day_count = data.get("day_count", 1)
	problems_solved_today = data.get("problems_solved_today",0)
	