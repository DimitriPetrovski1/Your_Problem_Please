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
@onready var score_label = $HUD/TextureRect/VBoxPoints/PointsLabel
@onready var lives_label = $HUD/TextureRect/VBoxLives/LivesLabel

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
	bg.position.y -= scroll_speed * delta
	
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
	
	# 2. NEW: Set a fixed height for all ads (adjust this number to your liking)
	var fixed_height = 120.0 
	
	# 3. Setup the ad using the height (Ad.gd now handles width proportionally)
	if new_ad.has_method("setup"):
		new_ad.setup(random_tex, fixed_height)
	
	# 4. Position it horizontally using your fixed points
	var possible_x = [10, 150, 300, 450]
	var selected_x = possible_x.pick_random()
	new_ad.position = Vector2(selected_x, get_viewport_rect().size.y + 60)
	
	# 5. Set speed and connect signals
	new_ad.speed = scroll_speed
	new_ad.ad_closed.connect(_on_ad_success)
	new_ad.ad_missed.connect(_on_ad_failure)
	
	ad_container.add_child(new_ad)
	
	# Randomize next spawn time
	spawn_timer.wait_time = randf_range(0.6, 1.0)

# --- GAMEPLAY LOGIC ---

func _on_ad_success():
	score += 1
	_update_ui()
	scroll_speed += 5.0

func _on_ad_failure():
	lives -= 1
	_update_ui()
	if lives <= 0:
		_game_over()

func _update_ui():
	# Update HUD labels if they are assigned
	if score_label: score_label.text = str(score)
	if lives_label: lives_label.text = str(lives)

func _game_over():
	spawn_timer.stop()
	set_process(false)
	
	var total_earned = score * payout_multiplier
	ShopGameData.add_money(total_earned)
	
	print("Game Over! Earned: $", total_earned)
	queue_free()

func _on_quit_button_pressed():
	queue_free()
