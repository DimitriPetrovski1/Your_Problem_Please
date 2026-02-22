extends Node

const SAVE_PATH := "user://shop_save.json"
var money: int = 100

signal equipment_changed
signal money_changed(new_amount)
signal bought_item

var owned_items: Array[String] = []
var equipped_items: Array[String] = []

func _ready():
	load_game()


func add_money(amount: int):
	money += amount
	save_game()
	money_changed.emit(money) # Tell everyone the money changed!
	

# =========================
# BUY
# =========================
func buy_item(id: String, price: int) -> bool:
	if id in owned_items:
		return false
	
	if money < price:
		return false
	
	money -= price
	money_changed.emit(money)
	owned_items.append(id)
	bought_item.emit(id)
	save_game()
	AchievementsManager.set_num_bought_items(AchievementsManager.num_bought_items+1)
	return true
	


func reset_shop()-> void:
	owned_items.clear()
	money=1000
	money_changed.emit(money)
	save_game()
	AchievementsManager.set_num_bought_items(0)
# =========================
# EQUIP
# =========================
func equip_item(id: String):
	if id in owned_items and not id in equipped_items:
		equipped_items.append(id)
		save_game()
		equipment_changed.emit()


func unequip_item(id: String):
	equipped_items.erase(id)
	save_game()
	equipment_changed.emit()


# =========================
# SAVE / LOAD
# =========================
func save_game():
	var data = {
		"money": money,
		"owned_items": owned_items,
		"equipped_items": equipped_items
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	var data = JSON.parse_string(json_string)
	
	if data == null:
		printerr("Failed to parse save file.")
		return

	# Simple variables (int, float, bool) work fine with '='
	money = data.get("money", 100)
	
	# Typed arrays need '.assign()' to transfer data safely
	if data.has("owned_items"):
		owned_items.assign(data.get("owned_items"))
		
	if data.has("equipped_items"):
		equipped_items.assign(data.get("equipped_items"))
