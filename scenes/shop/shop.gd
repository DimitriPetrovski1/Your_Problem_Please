extends Control
@export var frame_texture: Texture2D = preload("res://assets/UI/ShopItemFrame.png")

@export var accessories: Array[AccessoryData] = []
# Drag your frame image (the box/background) here in the inspector

@onready var grid = $"Background Back Button/TextureRect/ScrollContainer/GridContainer"

signal accessory_updated

func _ready():
	# 1. Load the accessories from the folder
	var folder = "res://scenes/shop/accessories/"
	var dir = DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var processed_files = [] # Prevent duplicates in editor
		while file_name != "":
			if not dir.current_is_dir():
				# Strip .remap and .import to get the base resource path
				var clean_name = file_name.replace(".remap", "").replace(".import", "")
				
				if clean_name.ends_with(".tres") and not clean_name in processed_files:
					var res = load(folder + clean_name)
					if res:
						accessories.append(res)
						processed_files.append(clean_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	accessories.sort_custom(func(a, b): return int(a.id) < int(b.id))

	# 2. Populate shop
	for accessory in accessories:
		# Create a Horizontal wrapper for each shop item
		var item_container = HBoxContainer.new()
		item_container.add_theme_constant_override("separation", 15)
		item_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(item_container)

		# --- THE FRAME & ACCESSORY STACK ---
		var frame_anchor = Control.new()
		frame_anchor.custom_minimum_size = Vector2(110, 140)
		item_container.add_child(frame_anchor)

		# The Background Frame
		var bg_frame = TextureRect.new()
		bg_frame.texture = frame_texture
		bg_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_frame.stretch_mode = TextureRect.STRETCH_SCALE
		bg_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		frame_anchor.add_child(bg_frame)

		# The Accessory (The "No-Code" Centering way)
		var tex_rect = TextureRect.new()
		tex_rect.texture = accessory.texture
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		if accessory.id not in ShopGameData.owned_items:
			tex_rect.modulate = Color(1,1,1,0.5)
		else:
			tex_rect.modulate = Color(1,1,1,1)
		tex_rect.offset_left = 15
		tex_rect.offset_top = 15
		tex_rect.offset_right = -15
		tex_rect.offset_bottom = -15
		tex_rect.name = "AccessoryIcon"
		frame_anchor.add_child(tex_rect)

		# --- THE BUTTON ---
		var btn = Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn.custom_minimum_size.y = 80
		btn.custom_minimum_size.x = 100
		btn.set_meta("accessory", accessory)

		if accessory.purchasable == false and accessory.id not in ShopGameData.owned_items:
			btn.disabled = true
			# Invisible overlay to catch clicks on the disabled button
			var overlay = Button.new()
			overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
			overlay.flat = true
			overlay.mouse_filter = Control.MOUSE_FILTER_STOP
			overlay.pressed.connect(_show_requirements_popup.bind(accessory))
			btn.add_child(overlay)
		else:
			btn.pressed.connect(_on_shop_item_pressed.bind(btn))

		item_container.add_child(btn)
	
	_update_buttons()


func _show_requirements_popup(accessory: AccessoryData) -> void:
	var popup = AcceptDialog.new()
	popup.title = "Locked!"
	popup.dialog_text = "How to unlock:\n%s" % accessory.obtainability_requirement_description # Change to whatever your field is called
	popup.confirmed.connect(popup.queue_free)
	popup.canceled.connect(popup.queue_free)
	add_child(popup)
	popup.popup_centered()

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

func _update_buttons():
	for item_container in grid.get_children():
		# 1. Get the Frame Anchor (Index 0) and then the Accessory Texture (Index 1 inside the anchor)
		var frame_anchor = item_container.get_child(0)
		var tex_rect = frame_anchor.get_node("AccessoryIcon")
		
		# 2. Get the Button (Index 1 of the item_container)
		var btn = item_container.get_child(1)
		
		var accessory: AccessoryData = btn.get_meta("accessory")
		
		# UPDATE ALPHA/VISUALS
		if accessory.id in ShopGameData.owned_items:
			tex_rect.modulate.a = 1.0 # Fully visible when owned
			
			# UPDATE BUTTON TEXT
			if accessory.id in ShopGameData.equipped_items:
				btn.text = "Unequip"
			else:
				btn.text = "Equip"
		else:
			tex_rect.modulate.a = 0.5 # Faded when not owned
			if accessory.purchasable == false:
				btn.text = "Requirements"
			else:
				btn.text = accessory.name + "\n$" + str(accessory.price)



func _on_background_back_button_button_down() -> void:
	queue_free()
