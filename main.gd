extends Node

var screen_size
var score
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport().size

func new_game():
	score = 0
	
	$Control/Rope.get_node("Timer").start()
	
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$BackgroundMusic.play()

func game_over() -> void:
	#$ScoreTimer.stop()
	$Control/Rope.get_node("Timer").stop()
	$HUD.show_game_over()
	$BackgroundMusic.stop()
	$GameOverMusic.play()

func _process(_delta: float) -> void:
	pass


func _on_rope_comleted_clothes(number_clothes_elements: int) -> void:
	score += number_clothes_elements
	$HUD.update_score(score)
