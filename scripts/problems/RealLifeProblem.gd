class_name RealLifeProblem
extends Problem

@export var description: String
@export var correct_choices:Array[String]

func get_category() -> String:
	return "REAL_LIFE"
	
func get_short_description() -> String:
	return "Should i be worried i could get hacked?"

func get_possible_choices() -> Array[String]:
	return [
		"Charging devices on public USB ports",
		"Plugging unknown USB drives into devices",
		"Sharing sensitive information on public Wi-Fi",
		"Scanning unknown QR codes",
		"Downloading apps from unofficial sources",
		"Posting personal info publicly",
	]
func get_correct_choices() -> Array[String]:
	return correct_choices
	
