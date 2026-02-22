extends Problem
class_name MinigameProblem

func get_category() -> String:
	return "MINIGAME"
	
func get_short_description() -> String:
	return "Can you close these ads for me?"

func get_possible_choices() ->  Array[String]:
	return [
"null"
	]
func get_correct_choices() -> Array[String]:
	return ["null"]
