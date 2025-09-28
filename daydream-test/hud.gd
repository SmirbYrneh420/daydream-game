extends CanvasLayer

signal start_game

func show_message(msg):
	$Title.text = msg
	$Title.show()
	$MessageTimer.start()

func game_over():
	show_message("GAME OVER")
	await $MessageTimer.timeout
	
	disable_player_input()
	$Title.text = "Testing Testing 123"
	$Title.show()
	$Polygon2D.show()
	$StartButton.show()
	
func _on_start_button_pressed():
	$StartButton.hide()
	$Polygon2D.hide()
	show_message("Escape!")
	enable_player_input()
	start_game.emit()
	Audio.play_sound("res://frames/floppy_countdown.mp3")

func _on_message_timer_timeout():
	$Title.hide()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func disable_player_input():
	# Disable input processing for all players
	var player = get_node("../Player")  # Adjust path to your player node
	if player:
		player.set_input_enabled(false)

func enable_player_input():
	# Enable input processing for all players
	var player = get_node("../Player")  # Adjust path to your player node
	if player:
		player.set_input_enabled(true)
