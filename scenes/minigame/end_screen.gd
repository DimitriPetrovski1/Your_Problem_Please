extends Control
var hasRevived=false

signal revive

@onready var score_label:Label = $Background/ScoreLabel
@onready var money_label:Label = $Background/MoneyLabel
@onready var revive_btn = $Background/HBoxContainer/ReviveButton

func show_screen(score:int,money:int):
	revive_btn.visible = not hasRevived
	score_label.text = "score earned: "+str(score)
	money_label.text = "money earned: $"+str(money)
	
func _on_revive_button_pressed() -> void:
	hasRevived = true
	revive.emit()
