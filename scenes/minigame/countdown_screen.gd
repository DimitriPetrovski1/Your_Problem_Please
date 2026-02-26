extends Control

@onready var label = $Background/ActionLabel
signal gotoPlayScreen

func countdown(action:String):
	for i in range(3,0,-1):
		label.text = action + " in: "+str(i)+"..."
		await get_tree().create_timer(1).timeout
	label.text = "GO!"
	await get_tree().create_timer(1).timeout
	gotoPlayScreen.emit(action)
		
	
