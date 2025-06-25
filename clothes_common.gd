extends PathFollow2D

@export var children_elements : Dictionary
@export var clothes_part : Area2D
@export var touch_area : Area2D

@onready var rope: Node2D = get_parent().get_parent()
@onready var connected_music: AudioStreamPlayer2D = rope.get_node("ConnectedMusic")
@onready var completed_music: AudioStreamPlayer2D = rope.get_node("CompletedMusic") 
 
var dragging: bool
var first_drag: bool
var touchPos: Vector2
var of: Vector2
var oldPosition: Vector2
#var oldProgress : float

func _input(event) -> void:	
	if dragging:
		first_drag = false
		touchPos = event.position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	if rope.help_clothes_part.size() > 0:
		spawn_clothes(rope.help_clothes_part[0])
		rope.help_clothes_part.erase(rope.help_clothes_part[0])
	else:
		spawn_clothes()

func _on_end_game() -> void:
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if dragging and not first_drag:
		clothes_part.global_position = touchPos
	
	if len(children_elements) > 1 or (not dragging and not first_drag):
		progress += rope.speed
	
func spawn_clothes(sceneName: String = "") -> void:
	var clothes_scene_element: Resource
	if sceneName.is_empty():
		clothes_scene_element = rope.clothes_scenes.values().pick_random()
	else:
		clothes_scene_element = rope.clothes_scenes[sceneName]
	clothes_part = clothes_scene_element.instantiate()
	#clothes_part.area_entered.connect(_on_area_entered)
	clothes_part.get_node("Button").gui_input.connect(_on_button_gui_input.bind(clothes_part))
	add_child(clothes_part)
	children_elements[clothes_part.name] = clothes_part
	rope.add_identical_element(clothes_part.name)

func _on_area_entered(area: Area2D) -> void:
	pass
	#if not rope.dragging:
		#if touch_area == null:
		#resolve_overlap(area, clothes_part)
			#area.get_parent().touch_area = area
		#else:
			#touch_area = null
			
	#area.get_parent().progress += 20

func _on_button_gui_input(event: InputEvent, pressed_clothes: Area2D) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			clothes_part = pressed_clothes
			dragging = true
			rope.dragging = true
			first_drag = true
			touchPos = event.position
			of = touchPos - clothes_part.position
			oldPosition = clothes_part.position
			#oldProgress = progress
			clothes_part.position = touchPos - of
		else:
			dragging = false
			rope.dragging = false
			clothes_part.position = oldPosition
			check_and_move_parts_clothes()
			#clothes_part.area_entered.emit(clothes_part)
		#rope.dragging = dragging
		
func check_and_move_parts_clothes() -> void:
	var overlapping_clothes = clothes_part.get_overlapping_areas()
	for clothes in clothes_part.get_overlapping_areas():
		if clothes.name == "HelpArea":
			continue
		var group_clothes = clothes.get_groups()[0]
		
		if group_clothes == clothes_part.get_groups()[0] and (clothes.name != clothes_part.name):
			connect_clothes(clothes, group_clothes)
		else:
			resolve_overlap(clothes, clothes_part)

func connect_clothes(clothes: Area2D, group_clothes: StringName) -> void:	
	var parent_clothes = clothes.get_parent()
	if parent_clothes == self:
		return		

	if group_clothes == "t_shirt" or group_clothes == "dress":
		if not clothes.name.contains("Base") and not clothes_part.name.contains("Base"):
			return
		if parent_clothes.children_elements.has(clothes_part.name):
			return
	
	rope.delete_identical_element(clothes_part.name)
	parent_clothes.spawn_clothes(clothes_part.name)	
	
	children_elements.erase(clothes_part.name)
	if children_elements.is_empty():
		#rope.delete_identical_element(clothes_part.name)
		queue_free()
	else:
		clothes_part.queue_free()
			
	parent_clothes.work_after_connect_clothes(group_clothes)
	work_after_connect_clothes(group_clothes)
			
func resolve_overlap(moving_area: Area2D, static_area: Area2D) -> void:
	var moving_shape = moving_area.get_node("CollisionShape2D").shape
	var static_shape = static_area.get_node("CollisionShape2D").shape

	# Получаем глобальные позиции
	var moving_pos = moving_area.global_position
	var static_pos = static_area.global_position

	# Для примера считаем, что оба shape — RectangleShape2D
	if moving_shape is RectangleShape2D and static_shape is RectangleShape2D:
		var moving_rect = Rect2(
			moving_pos - moving_shape.extents,
			moving_shape.extents * 2
		)
		var static_rect = Rect2(
			static_pos - static_shape.extents,
			static_shape.extents * 2
		)
		
		if moving_rect.intersects(static_rect):
			var overlap_rect = moving_rect.intersection(static_rect)
			var mtv = 0.0

		# Сдвигаем по X
		#if moving_rect.position.x < static_rect.position.x:
			#mtv = overlap_rect.size.x
		#else:
			#mtv = -overlap_rect.size.x
			if moving_rect.position.x < static_rect.position.x:
				mtv = overlap_rect.size.x
			else:
				mtv = -overlap_rect.size.x
				
			#static_area.position += mtv
			progress += mtv * 2
			resolve_overlap(moving_area, static_area) 

func work_after_connect_clothes(group_clothes: StringName) -> void:
	var number_elements_in_group = 0
	if group_clothes == "pants":
		connected_pants()
		number_elements_in_group = 2
	elif group_clothes == "socks":
		number_elements_in_group = 2
	elif group_clothes == "t_shirt":
		connected_t_shirts()
		number_elements_in_group = 3
	elif group_clothes == "dress":
		connected_dresses()
		number_elements_in_group = 4
	
	if len(children_elements) == number_elements_in_group:
		rope.comleted_clothes.emit(number_elements_in_group)
		spawn_full_clothes(group_clothes)
		completed_music.play()
	else:
		connected_music.play()

func connected_pants() -> void:	
	if clothes_part.name == "pants_left":
		clothes_part.position = Vector2(-40, 0)
	else:
		clothes_part.position = Vector2(40, 0)
		
func connected_t_shirts() -> void:
	
	if len(children_elements) == 1:
		for clothes_element in children_elements:
			children_elements[clothes_element].position = Vector2(0, 0)
			return
	
	for clothes_element in children_elements:
		if clothes_element == "T_ShirtLeft":
			children_elements[clothes_element].position = Vector2(-45, 27)
		elif clothes_element == "T_ShirtRight":
			children_elements[clothes_element].position = Vector2(82, 27)
		else:
			children_elements[clothes_element].position = Vector2(0, 0)

func connected_dresses() -> void:
	
	if len(children_elements) == 1:
		for clothes_element in children_elements:
			children_elements[clothes_element].position = Vector2(0, 0)
			return
			
	for clothes_element in children_elements:
		if clothes_element == "DressSleeveLeft":
			children_elements[clothes_element].position = Vector2(-43, 3.5)
		elif clothes_element == "DressSleeveRight":
			children_elements[clothes_element].position = Vector2(60, 4)
		elif clothes_element == "DressSkirt":
			children_elements[clothes_element].position = Vector2(-12, 101)
		else:
			children_elements[clothes_element].position = Vector2(0, 0)
	
func spawn_full_clothes(group_clothes: StringName) -> void:
	var clothes_full: RigidBody2D
	clothes_full = rope.clothes_full_scenes[group_clothes].instantiate()
	clothes_full.global_position = clothes_part.global_position
	clothes_full.get_node("VisibleOnScreenEnabler2D").screen_exited.connect(Callable(rope,
		"_on_visible_on_screen_enabler_2d_screen_exited").bind(clothes_full))
	rope.add_child(clothes_full)
	for child in children_elements:
		rope.delete_identical_element(child)
	queue_free()
		
	
