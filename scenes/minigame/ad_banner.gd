extends TextureRect

signal ad_closed
signal ad_missed

var speed: float = 250.0

@onready var close_button = $"Close Button"

func _ready():
	close_button.pressed.connect(_on_close_button_pressed)

# Changed 'target_width' to 'target_height'
func setup(tex: Texture2D, target_height: float):
	texture = tex
	
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE 
	
	# Calculate width to maintain aspect ratio based on a FIXED height
	# Formula: Width = Height * (Original Width / Original Height)
	var aspect_ratio = tex.get_size().x / tex.get_size().y
	var target_width = target_height * aspect_ratio
	
	# Set the size so height is always the same
	custom_minimum_size = Vector2(target_width, target_height)
	size = custom_minimum_size

func _process(delta: float):
	position.y -= speed * delta
	
	if position.y + size.y < 0:
		ad_missed.emit()
		queue_free()

func _on_close_button_pressed():
	ad_closed.emit()
	print("Ad closed")
	queue_free()
