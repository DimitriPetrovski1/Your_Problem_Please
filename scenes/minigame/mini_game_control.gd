extends Node
enum GameState {START,PLAY,COUNTDOWN,END}
signal MinigameOver

var money_earned:=0
var score_earned:=0
var revive_cost := 50
@onready var screens := {
	GameState.START: $StartScreen,
	GameState.PLAY: $PlayScreen,
	GameState.COUNTDOWN: $CountdownScreen,
	GameState.END: $EndScreen
}

@onready var music_player = $MusicPlayer

func show_screen(screen:GameState):
	for s in screens.values():
		s.visible = false
	screens.get(screen).visible=true
		
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_player.play()
	$CountdownScreen.gotoPlayScreen.connect(_on_goto_PlayScreen)
	$PlayScreen.gotoEndScreen.connect(_on_goto_EndScreen)
	$EndScreen.revive.connect(_on_revive)
	show_screen(GameState.START)

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_pass_button_pressed() -> void:
	MinigameOver.emit(0)
	queue_free()


func _on_exit_button_pressed() -> void:
	ShopGameData.add_money(money_earned)
	MinigameOver.emit(score_earned)
	queue_free()

func _on_goto_PlayScreen(action):
	show_screen(GameState.PLAY)
	if action == "Reviving":
		screens.get(GameState.PLAY).revive()
	else:
		screens.get(GameState.PLAY).start()


func _on_goto_EndScreen(score:int,money:int):
	money_earned=money
	score_earned=score
	screens.get(GameState.END).show_screen(score_earned,money_earned)
	show_screen(GameState.END)


func _on_start_button_pressed() -> void:
	var action := "Starting"
	screens.get(GameState.COUNTDOWN).countdown(action)
	show_screen(GameState.COUNTDOWN)



func _on_revive():
	ShopGameData.add_money(-revive_cost)
	var action := "Reviving"
	screens.get(GameState.COUNTDOWN).countdown(action)
	show_screen(GameState.COUNTDOWN)

	
