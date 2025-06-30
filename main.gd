extends Node

@export var score: int

var screen_size
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport().size

func new_game():
	score = 0
	
	$Rope.get_node("Timer").start()
	
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$BackgroundMusic.play()

func game_over() -> void:
	#$ScoreTimer.stop()
	$Rope.get_node("Timer").stop()
	$HUD.show_game_over()
	$BackgroundMusic.stop()
	$GameOverMusic.play()

func _process(_delta: float) -> void:
	pass


func get_updated_score(number_clothes_elements: int) -> int:
	score += number_clothes_elements
	$HUD.update_score(score)
	return score
