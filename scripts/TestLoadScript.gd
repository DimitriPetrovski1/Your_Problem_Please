extends Node

func _ready():
	var path = "res://game_data/problems/email/phishing_coupon.tres"
	
	var problem = ResourceLoader.load(path)
	
	if problem == null:
		print("❌ Failed to load resource at ", path)
		return
	
	# Check the type
	if problem is EmailProblem:
		print("✅ Successfully loaded EmailProblem")
	else:
		print("⚠ Loaded resource, but not EmailProblem. Type:", problem.get_class())

	# Print its data
	var category = ""
	if problem is EmailProblem:
		category = "EMAIL"
		print("Category:", category)
		print("Sender:", problem.sender)
		print("Subject:",problem.subject)
		print("Body:",problem.body)
		for action in problem.get_correct_choices():
			print(action)
		for choice in problem.get_possible_choices():
			print("-",choice)

	if problem is MessagesProblem:
		category  = "MESSSAGES"
	if problem is RealLifeProblem:
		category  = "REAL_LIFE"
	
	
