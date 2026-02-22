extends Label

func _ready() -> void:
	
	
	# 1. Safety check to prevent the 'null instance' crash
	
	var text_to_display := "Day " + str(GameInfo.day_count)
	if GameInfo.problems_solved_today!=0:
		text_to_display = "Continuing Day " + str(GameInfo.day_count)
	# 2. Convert integer to string using str()
	else:
		GameInfo.increment_day()
		
	text = text_to_display
	
	# 3. Modify and save using ResourceSaver
	await get_tree().create_timer(2.0).timeout
	
	Transition.transition_to("res://scenes/gameplay_scene_1.tscn")
