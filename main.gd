extends Node

@export var score: int

var screen_size
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport().size
	#var base_size = get_tree().root.content_scale_size
	#var scale = min(screen_size.x / base_size.x, screen_size.y / base_size.y)
	#if screen_size > base_size:
	#get_tree().root.content_scale_factor = 1.2
	
func new_game():
	score = 0
	
	$ControlRope/Rope.get_node("Timer").start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$BackgroundMusic.play()

func game_over() -> void:
	#$ScoreTimer.stop()
	$ControlRope/Rope.get_node("Timer").stop()
	$HUD.show_game_over()
	$BackgroundMusic.stop()
	$GameOverMusic.play()

func _process(_delta: float) -> void:
	pass


func get_updated_score(number_clothes_elements: int) -> int:
	score += number_clothes_elements
	$HUD.update_score(score)
	return score
