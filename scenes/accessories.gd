extends Control

func _ready():
	_refresh_accessories()
	ShopGameData.equipment_changed.connect(_refresh_accessories)

func _refresh_accessories():
	for accessory_node in get_children():
		# Ensure the node is actually visible to the engine logic
		accessory_node.show() 
		
		if accessory_node.name in ShopGameData.owned_items and accessory_node.name in ShopGameData.equipped_items:
			# Fully visible (Opaque)
			accessory_node.modulate.a = 1.0
		else:
			# Fully invisible but still takes up space (Transparent)
			accessory_node.modulate.a = 0.0
