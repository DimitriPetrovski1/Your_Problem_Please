class_name EmailProblem
extends Problem

@export var sender: String
@export var subject: String
@export var body: String
@export var correct_choices:Array[String]

func get_category() -> String:
	return "EMAIL"
	
func get_short_description() -> String:
	return "I got this email but I can't tell if it's fake!"

func get_possible_choices() -> Array[String]:
	return [
		"Too good to be true",
		"Suspicious sender",
		"Too urgent",
		"Requests sensitive information",
	]
func get_correct_choices() -> Array[String]:
	return correct_choices
	
