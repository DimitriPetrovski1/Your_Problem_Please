extends TextureRect # Changed from TextureButton

signal ad_closed
signal ad_missed

var speed: float = 250.0

@onready var close_button = $"Close Button"

func _ready():
	# Connect the child button's signal to our internal function
	close_button.pressed.connect(_on_close_button_pressed)

func setup(tex: Texture2D, target_width: float):
	texture = tex
	
	# --- THE FIX ---
	# This allows the TextureRect to be smaller/larger than the actual image file
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	# This ensures the image stretches to fill the whole area
	stretch_mode = TextureRect.STRETCH_SCALE 
	
	# Calculate height to maintain aspect ratio
	# $$ \text{Height} = \text{Target Width} \times \left( \frac{\text{Original Height}}{\text{Original Width}} \right) $$
	var aspect_ratio = tex.get_size().y / tex.get_size().x
	var target_height = target_width * aspect_ratio
	
	# Set the size
	custom_minimum_size = Vector2(target_width, target_height)
	size = custom_minimum_size

func _process(delta: float):
	position.y -= speed * delta
	
	if position.y + size.y < 0:
		ad_missed.emit()
		queue_free()

# This is called ONLY when the 'X' is clicked
func _on_close_button_pressed():
	ad_closed.emit()
	print("Ad closed")
	queue_free()
