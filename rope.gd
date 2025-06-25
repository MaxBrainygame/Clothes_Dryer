extends Node2D

@export var clothes_common_scene: PackedScene
@export var dragging: bool
@export var speed: float = 1
@export var complexity_clothes: int = 2
@export var number_identical_elements_together: int = 1
@export var identical_elements: Dictionary
@export var clothes_scenes: Dictionary
@export var help_clothes_part: Array[String]

@export var clothes_full_scenes = {
	"pants": preload("res://pants_full.tscn"),
	"t_shirt": preload("res://t_shirt_full.tscn"),
	"dress": preload("res://dress_full.tscn"),
	"socks": preload("res://socks_full.tscn")
}

signal hit
signal comleted_clothes

@onready var path_clothes = $Path2D
#@onready var mainRoot: Node = get_tree().root
@onready var oldScore: int = 0
@onready var points_increase_difficulty = 10

const clothes_scenes_two_part = {
	"pants_left": preload("res://pants_left.tscn"),
	"pants_right": preload("res://pants_right.tscn"),
	"SocksLeft": preload("res://socks_left.tscn"),
	"SocksRight": preload("res://socks_right.tscn"),
}

const clothes_scenes_three_part = {
	"T_ShirtLeft": preload("res://t_shirt_left.tscn"),
	"T_ShirtRight": preload("res://t_shirt_right.tscn"),
	"T_ShirtBase": preload("res://t_shirt_middle.tscn")
}

const clothes_scenes_four_part = {
	"DressSkirt": preload("res://dress_skirt.tscn"),
	"DressSleeveRight": preload("res://dress_sleeve_right.tscn"),
	"DressSleeveLeft": preload("res://dress_sleeve_left.tscn"),
	"DressBase": preload("res://dress_t_shirt.tscn")	
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#hide()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	spawn_common_clothes()
	
func spawn_common_clothes() -> void:
	
	set_available_clothes_scenes()
	
	if clothes_scenes.is_empty():
		return
	
	var clothes_common = clothes_common_scene.instantiate()
	path_clothes.add_child(clothes_common)

func set_available_clothes_scenes() -> void:
	if complexity_clothes <= 2:
		clothes_scenes.merge(clothes_scenes_two_part)
	elif complexity_clothes <= 3:
		clothes_scenes.merge(clothes_scenes_two_part)
		clothes_scenes.merge(clothes_scenes_three_part)
	else: # complexity_clothes == 4
		clothes_scenes.merge(clothes_scenes_two_part)
		clothes_scenes.merge(clothes_scenes_three_part)
		clothes_scenes.merge(clothes_scenes_four_part)
	
	for scene in clothes_scenes.keys():
		var numbers_on_screen = identical_elements.get(scene)
		if numbers_on_screen != null and numbers_on_screen == number_identical_elements_together:
			clothes_scenes.erase(scene)
	
func _on_visible_on_screen_enabler_2d_screen_exited(clothes_full: RigidBody2D) -> void:
	clothes_full.queue_free()
	
func _on_game_over_area_area_entered(area: Area2D) -> void:
	var children_path_clothes = path_clothes.get_children()
	for clothes_path in children_path_clothes:
		clothes_path.queue_free()
	hit.emit()

func _on_hud_pause() -> void:
	get_tree()

func add_identical_element(clothes_part_name: String) -> void:
	var identical_scene_numbers = identical_elements.get_or_add(clothes_part_name, 0)
	identical_elements[clothes_part_name] = identical_scene_numbers + 1
	
func delete_identical_element(clothes_part_name: String) -> void:
	var identical_scene_numbers = identical_elements.get_or_add(clothes_part_name, 0)
	identical_elements[clothes_part_name] = identical_scene_numbers - 1
	if identical_elements[clothes_part_name] < 0:
		identical_elements.erase(clothes_part_name)
	elif identical_elements[clothes_part_name] == 0:
		set_available_clothes_scenes()

func after_update_result(score: int) -> void:
	if score - oldScore >= points_increase_difficulty:
		if speed < 3:
			speed += 0.2
		if $Timer.wait_time > 1.5:
			$Timer.wait_time = $Timer.wait_time - 0.1
		if complexity_clothes < 4:
			complexity_clothes += 1
		#if number_identical_elements_together < 3:
			#number_identical_elements_together += 1
		oldScore = score
		points_increase_difficulty * 2

func _on_help_area_area_entered(area: Area2D) -> void:	
	var group = area.get_groups()[0]
	var clothes_in_group = get_tree().get_nodes_in_group(group)
	if (group == "pants" or group == "socks") and clothes_in_group.size() < 2:	
		find_help_clothes_part(clothes_scenes_two_part.duplicate(), group, clothes_in_group)	
	elif group == "t_shirt" and clothes_in_group.size() < 3:
		find_help_clothes_part(clothes_scenes_three_part.duplicate(), group, clothes_in_group)
	elif group == "dress" and clothes_in_group.size() < 4:
		find_help_clothes_part(clothes_scenes_four_part.duplicate(), group, clothes_in_group) 

func find_help_clothes_part(clothes_scenes_help: Dictionary, group: StringName, clothes_in_group: Array[Node]):
		for clothes_name in clothes_scenes_help.keys():
			if not clothes_name.containsn(group):
				clothes_scenes_help.erase(clothes_name)
				
		for clothes in clothes_in_group:
			if clothes_scenes_help.has(clothes.name):
				clothes_scenes_help.erase(clothes.name)
				
		if not clothes_scenes_help.is_empty():
			help_clothes_part.append_array(clothes_scenes_help.keys())			
