extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game
signal pause

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Clothes Dryer"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	$PauseButton.hide()

func update_score(score):
	$ScoreLabel.text = str(score)

func _on_button_pressed() -> void:
	$StartButton.hide()
	$PauseButton.show()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()

func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$PauseBackground.show()
	$PlayButton.show()

func _on_play_button_pressed() -> void:
	get_tree().paused = false
	$PauseBackground.hide()
	$PlayButton.hide()
