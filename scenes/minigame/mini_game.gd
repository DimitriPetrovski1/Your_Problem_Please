extends Control

# --- EXPORTS ---
@export var ad_scene: PackedScene = preload("res://scenes/minigame/Ad.tscn")
@export var ad_textures: Array[Texture2D] = []
@export var ads_folder_path: String = "res://assets/ads/"

# --- SETTINGS ---
var scroll_speed: float = 250.0
var score: int = 0
var lives: int = 3
var payout_multiplier: int = 5 # $5 per successful click

# --- NODES ---
@onready var bg = $"Website Background"
@onready var ad_container = $"Ad Container"
@onready var spawn_timer = $"Spawn Timer"
@onready var score_label = $HUD/ScoreLabel
@onready var lives_label = $HUD/LivesLabel

func _ready() -> void:
	# 1. Load textures from folder automatically if array is empty
	if ad_textures.is_empty():
		_load_ads_from_folder()
	
	# 2. Setup Timer
	spawn_timer.timeout.connect(_spawn_ad)
	spawn_timer.wait_time = 1.0
	spawn_timer.start()
	
	# 3. Initialize UI
	_update_ui()

func _process(delta: float) -> void:
	# Endless background scrolling logic
	# Note: This assumes your Background TextureRect is set to "Tile" mode
	bg.position.y -= scroll_speed * delta
	
	# Reset position for seamless loop
	if bg.texture and bg.position.y <= -bg.texture.get_size().y:
		bg.position.y = 0

func _load_ads_from_folder():
	var dir = DirAccess.open(ads_folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".webp"):
				var tex = load(ads_folder_path + file_name)
				if tex:
					ad_textures.append(tex)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Error: Could not find ads folder at ", ads_folder_path)

func _spawn_ad():
	if ad_textures.is_empty() or ad_scene == null:
		return
		
	var new_ad = ad_scene.instantiate()
	
	# 1. Pick random texture
	var random_tex = ad_textures.pick_random()
	
	# 2. Determine a random width (e.g., between 180 and 350 pixels)
	var target_width = randf_range(180.0, 350.0)
	
	# 3. Setup the ad's texture and size (Calling the function in Ad.gd)
	if new_ad.has_method("setup"):
		new_ad.setup(random_tex, target_width)
	
	# 4. Position it horizontally (ensuring it stays on screen)
	var screen_w = get_viewport_rect().size.x
	var random_x = randf_range(0, screen_w - new_ad.size.x)
	new_ad.position = Vector2(random_x, get_viewport_rect().size.y + 50)
	
	# 5. Set speed and connect signals
	new_ad.speed = scroll_speed
	new_ad.ad_closed.connect(_on_ad_success)
	new_ad.ad_missed.connect(_on_ad_failure)
	
	ad_container.add_child(new_ad)
	
	# Randomize next spawn time
	spawn_timer.wait_time = randf_range(0.4, 1.2)

# --- GAMEPLAY LOGIC ---

func _on_ad_success():
	score += 1
	_update_ui()
	# Increase difficulty slightly
	scroll_speed += 5.0

func _on_ad_failure():
	lives -= 1
	_update_ui()
	if lives <= 0:
		_game_over()

func _update_ui():
	pass
	#score_label.text = "Clicks: " + str(score)
	#lives_label.text = "Lives: " + str(lives)

func _game_over():
	# Stop everything
	spawn_timer.stop()
	set_process(false)
	
	# Calculate payout
	var total_earned = score * payout_multiplier
	ShopGameData.add_money(total_earned)
	
	print("Game Over! Earned: $", total_earned)
	
	# You can replace this with a Results Screen later
	# For now, we just close the minigame
	queue_free()

func _on_quit_button_pressed():
	# Optional manual exit
	queue_free()
