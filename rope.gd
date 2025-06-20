extends Node2D

@export var clothes_common_scene: PackedScene
@export var dragging: bool

signal hit
signal comleted_clothes

@onready var path_clothes = $Path2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	spawn_common_clothes()
	
func spawn_common_clothes() -> void:
	var clothes_common = clothes_common_scene.instantiate()
	path_clothes.add_child(clothes_common)
	
func _on_visible_on_screen_enabler_2d_screen_exited(clothes_full: RigidBody2D) -> void:
	clothes_full.queue_free()
	
func _on_game_over_area_area_entered(area: Area2D) -> void:
	var children_path_clothes = path_clothes.get_children()
	for clothes_path in children_path_clothes:
		clothes_path.queue_free()
	hit.emit()


func _on_hud_pause() -> void:
	get_tree()
