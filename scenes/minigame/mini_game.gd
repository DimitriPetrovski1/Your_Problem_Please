extends Control

signal gotoEndScreen

# --- EXPORTS ---
@export var ad_scene: PackedScene = preload("res://scenes/minigame/Ad.tscn")
@export var ad_textures: Array[Texture2D] = []
@export var ads_folder_path: String = "res://assets/ads/"

# --- SETTINGS ---
var scroll_speed: float = 250.0
var scroll_speed_speedup := 5
var score: int = 0
var lives: int = 3
var lost: bool = false
var payout_multiplier: int = 5 # $5 per successful click
var speed_multiplier_after_revive := 0.8

# --- NODES ---
@onready var bg: TextureRect = $"Website Background"
@onready var ad_container: Control = $"Ad Container"
@onready var spawn_timer:Timer = $SpawnTimer
@onready var score_label:Label = $HUD/PointAndLivesRect/VBoxPoints/PointsLabel
@onready var lives_label:Label = $HUD/PointAndLivesRect/VBoxLives/LivesLabel
@onready var score_lives_rect:TextureRect= $HUD/PointAndLivesRect
@onready var ad_closed: AudioStreamPlayer = $AdClosePlayer
@onready var ad_passed: AudioStreamPlayer = $AdPassedPlayer


# --- GAME OVER UI ---
var game_over_panel: Panel
var game_over_label: Label
var exit_button: TextureButton

func _ready() -> void:
	# 1. Load textures from folder automatically if array is empty
	if ad_textures.is_empty():
		_load_ads_from_folder()
	
	# 2. Setup Timer
	spawn_timer.timeout.connect(_spawn_ad)
	spawn_timer.wait_time = 1.0
	
	# 3. Initialize UI
	set_process(false)
	
func start():
	_update_ui()
	set_process(true)
	spawn_timer.start()
	
func revive():
	scroll_speed*=speed_multiplier_after_revive
	lives = 3
	start()
	
func _process(delta: float) -> void:
	if not visible:
		return
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
			if not dir.current_is_dir():
				# 1. Strip remap/import to get the 'Editor' path
				var clean_name = file_name.replace(".remap", "").replace(".import", "")
				
				# 2. Check extension on the CLEANED name
				if clean_name.ends_with(".png") or clean_name.ends_with(".jpg") or clean_name.ends_with(".webp"):
					var full_path = ads_folder_path + clean_name
					var tex = load(full_path)
					if tex:
						ad_textures.append(tex)
			file_name = dir.get_next()
		dir.list_dir_end()
		
func _spawn_ad():
	if ad_textures.is_empty() or ad_scene == null:
		return
		
	var new_ad = ad_scene.instantiate()
	
	# 1. Pick random texture
	var random_tex = ad_textures.pick_random()
	
	# 2. Set a fixed height for all ads
	var fixed_height = 120.0 
	
	# 3. Setup the ad using the height
	if new_ad.has_method("setup"):
		new_ad.setup(random_tex, fixed_height)
	
	# 4. Position it horizontally using fixed points
	var possible_x = [10, 150, 300, 450]
	var selected_x = possible_x.pick_random()
	new_ad.position = Vector2(selected_x, get_viewport_rect().size.y + 60)
	
	# 5. Set speed and connect signals
	new_ad.speed = scroll_speed
	new_ad.ad_closed.connect(_on_ad_success)
	new_ad.ad_missed.connect(_on_ad_failure)
	
	ad_container.add_child(new_ad)
	
	# Randomize next spawn time
	spawn_timer.wait_time = randf_range(0.8, 1.2)

# --- GAMEPLAY LOGIC ---
func _on_ad_success():
	ad_closed.play()
	score += 1
	_update_ui()
	scroll_speed += scroll_speed_speedup

func end_game():
	set_process(false)
	for child in ad_container.get_children():
		child.queue_free()
		
	var money_earned := score*payout_multiplier
	spawn_timer.stop()
	gotoEndScreen.emit(score,money_earned)

func _on_ad_failure():
	ad_passed.play()
	lives -= 1
	_update_ui()
	if lives <= 0:
		end_game()

func _update_ui():
	if score_label: score_label.text = str(score)
	if lives_label: lives_label.text = str(lives)
