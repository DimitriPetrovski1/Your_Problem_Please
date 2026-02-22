extends Control

signal MinigameOver

# --- EXPORTS ---
@export var ad_scene: PackedScene = preload("res://scenes/minigame/Ad.tscn")
@export var ad_textures: Array[Texture2D] = []
@export var ads_folder_path: String = "res://assets/ads/"

# --- SETTINGS ---
var scroll_speed: float = 250.0
var score: int = 0
var lives: int = 3
var lost: bool = false
var payout_multiplier: int = 5 # $5 per successful click

# --- NODES ---
@onready var bg = $"Website Background"
@onready var ad_container = $"Ad Container"
@onready var spawn_timer = $"Spawn Timer"
@onready var score_label = $HUD/PointAndLivesRect/VBoxPoints/PointsLabel
@onready var lives_label = $HUD/PointAndLivesRect/VBoxLives/LivesLabel
@onready var score_lives_rect = $HUD/PointAndLivesRect


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
	spawn_timer.start()
	
	# 3. Initialize UI
	_update_ui()
	
	# 4. Create game over UI (hidden initially)
	_create_game_over_ui()

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
	spawn_timer.wait_time = randf_range(0.6, 1.0)

# --- GAMEPLAY LOGIC ---
func _on_ad_success():
	score += 1
	_update_ui()
	scroll_speed += 5.0

func _on_ad_failure():
	if lost: return
	lives -= 1
	_update_ui()
	if lives <= 0:
		lost = true
		_game_over()

func _update_ui():
	if score_label: score_label.text = str(score)
	if lives_label: lives_label.text = str(lives)

func _create_game_over_ui():
	# Semi-transparent background panel covering the full screen
	game_over_panel = Panel.new()
	game_over_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_panel.visible = false
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.7)
	game_over_panel.add_theme_stylebox_override("panel", style_box)
	
	# CenterContainer fills the panel and centers its child perfectly
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# VBoxContainer holds the label and button stacked vertically
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	
	var byte_bounce = load("res://assets/Fonts/ByteBounce.ttf")

	# Game over label
	game_over_label = Label.new()
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.text = "GAME OVER!"
	game_over_label.add_theme_font_size_override("font_size", 48)
	game_over_label.add_theme_color_override("font_color", Color.WHITE)
	if byte_bounce:
		game_over_label.add_theme_font_override("font", byte_bounce)

	# Label inside the button — created first so we can measure its minimum size
	var btn_label = Label.new()
	btn_label.text = "Continue"
	btn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	btn_label.add_theme_font_size_override("font_size", 24)
	btn_label.add_theme_color_override("font_color", Color.WHITE)
	btn_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if byte_bounce:
		btn_label.add_theme_font_override("font", byte_bounce)

	# Measure label size and add padding so the texture wraps snugly around the text
	var padding = Vector2(24, 12)
	var label_min = btn_label.get_minimum_size()
	var btn_size = label_min + padding * 2

	# TextureButton sized to fit the label
	exit_button = TextureButton.new()
	exit_button.texture_normal = load("res://assets/UI/Buttons/Blue Button.png")
	exit_button.custom_minimum_size = btn_size
	exit_button.ignore_texture_size = true
	exit_button.stretch_mode = TextureButton.STRETCH_SCALE
	exit_button.pressed.connect(_on_exit_button_pressed)

	# Anchor the label to fill the button so it stays centered
	btn_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	exit_button.add_child(btn_label)
	
	vbox.add_child(game_over_label)
	vbox.add_child(exit_button)
	
	center.add_child(vbox)
	game_over_panel.add_child(center)
	add_child(game_over_panel)

func _game_over():
	spawn_timer.stop()
	set_process(false)
	score_lives_rect.visible = false
	
	# Calculate earnings
	var total_earned = score * payout_multiplier
	ShopGameData.add_money(total_earned)
	
	# Update and show game over UI
	game_over_label.text = "GAME OVER!\n\nScore: %d\nEarned: $%d" % [score, total_earned]
	game_over_panel.visible = true
	
	print("Game Over! Earned: $", total_earned)

func _on_exit_button_pressed():
	MinigameOver.emit(score)
	queue_free()

func _on_quit_button_pressed():
	queue_free()
