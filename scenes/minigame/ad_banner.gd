extends TextureButton

signal ad_closed
signal ad_missed

var speed: float = 250.0

# This will be set by the spawner
func setup(tex: Texture2D, target_width: float):
	texture_normal = tex
	
	# Calculate height to maintain aspect ratio
	# Formula: (Original Height / Original Width) * New Width
	var aspect_ratio = tex.get_size().y / tex.get_size().x
	var target_height = target_width * aspect_ratio
	
	# Set the size of the button
	custom_minimum_size = Vector2(target_width, target_height)
	size = custom_minimum_size

func _process(delta: float):
	position.y -= speed * delta
	if position.y + size.y < 0:
		ad_missed.emit()
		queue_free()

func _pressed():
	ad_closed.emit()
	queue_free()
