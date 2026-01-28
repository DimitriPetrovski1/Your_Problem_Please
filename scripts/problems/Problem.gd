@abstract 
class_name  Problem
extends Resource

@abstract func get_category() -> String
@abstract func get_short_description() -> String
@abstract func get_possible_choices() -> Array[String]
@abstract func get_correct_choices() -> Array[String]