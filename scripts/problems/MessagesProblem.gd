extends Problem
class_name MessagesProblem

@export var sender_name:String
@export var isFriend:bool
#intended array of messages, string "ATTATCHMENT" denotes the attatchment icon to be rendered instead of text message
@export var messages:Array[String]

@export var correct_choices:Array[String]

func get_category() -> String:
	return "MESSAGE"
	
func get_short_description() -> String:
	return "I got some weird messages. I cant tell if they're real!"

func get_possible_choices() ->  Array[String]:
	return [
		"Suspicious sender",
		"Urgent language",
		"Suspicious link or attatchment",
		"Requests sensitive information",
	]
func get_correct_choices() -> Array[String]:
	return correct_choices