extends Control

@export var accessories: Array[AccessoryData] = []

@onready var vbox = $"Background Back Button/TextureRect/VBoxContainer"

signal accessory_updated

func _ready():
	var folder = "res://scenes/shop/accessories/"
	var dir = DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var res = load(folder + file_name)
				if res:
					accessories.append(res)
			file_name = dir.get_next()
		dir.list_dir_end()

	# Populate shop
	for accessory in accessories:
		# 1. Create a Horizontal wrapper
		var item_container = HBoxContainer.new()
		item_container.add_theme_constant_override("separation", 10) # Space between icon and button
		vbox.add_child(item_container)

		# 2. Create the Texture (Left)
		var tex_rect = TextureRect.new()
		tex_rect.texture = accessory.texture
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.custom_minimum_size = Vector2(64, 64) # Square icon size
		item_container.add_child(tex_rect)

		# 3. Create the Button (Right)
		var btn = Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL # Button takes the rest of the width
		btn.custom_minimum_size.y = 64 # Match the icon height
		btn.set_meta("accessory", accessory)
		btn.pressed.connect(_on_shop_item_pressed.bind(btn))
		item_container.add_child(btn)
	
	_update_buttons()

# Button press callback (Unchanged)
func _on_shop_item_pressed(btn: Button):
	var accessory: AccessoryData = btn.get_meta("accessory")
	
	if accessory.id in ShopGameData.owned_items:
		if accessory.id in ShopGameData.equipped_items:
			ShopGameData.unequip_item(accessory.id)
		else:
			ShopGameData.equip_item(accessory.id)
	else:
		ShopGameData.buy_item(accessory.id, accessory.price)
	
	_update_buttons()
	accessory_updated.emit() 

# Update button text (Unchanged)
func _update_buttons():
	for item_container in vbox.get_children():
		var btn = item_container.get_child(1) # The button is still the 2nd child
		var accessory: AccessoryData = btn.get_meta("accessory")
		
		if accessory.id in ShopGameData.owned_items:
			if accessory.id in ShopGameData.equipped_items:
				btn.text = accessory.name + " (Equipped)"
			else:
				btn.text = accessory.name + " (Owned)"
		else:
			btn.text = accessory.name + " - $" + str(accessory.price)

func _on_color_rect_pressed() -> void:
	queue_free()
