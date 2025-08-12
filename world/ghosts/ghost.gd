class_name Ghost
extends CharacterBody2D


signal enter_frightened
signal exit_frightened

enum BehaviorMode { IDLE, CHASING, SCATTERING, FRIGHTENED }

const TILE_SIZE: int = 16

var screen_size: Vector2
var direction: Vector2 = Vector2.ZERO
var current_state: BehaviorMode = BehaviorMode.IDLE
var previous_state: BehaviorMode
var start_position: Vector2
var scatter_count: int = 0
var frightened_speed: float = 25.0
var regular_speed: float = 50.0
var current_speed: float = regular_speed

@onready var nav_agent := $NavigationAgent2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	hide()
	screen_size = get_viewport_rect().size
	add_to_group("enemy")
	$AnimatedSprite2D.play("default")
	
	# Navigation Agent
	nav_agent.process_mode = Node.PROCESS_MODE_PAUSABLE
	nav_agent.target_desired_distance = 8.0
	nav_agent.path_desired_distance = 8.0

func _physics_process(delta: float) -> void:
	match current_state:
		BehaviorMode.IDLE:
			direction = Vector2.ZERO
			velocity = Vector2.ZERO
		BehaviorMode.SCATTERING:
			scatter()
		BehaviorMode.CHASING:
			chase()
		BehaviorMode.FRIGHTENED:
			become_frightened()
	
	if not nav_agent.is_navigation_finished():
		var next_point = nav_agent.get_next_path_position()
		direction = (next_point - global_position).normalized()
	else:
		direction = Vector2.ZERO
	
	velocity = direction * current_speed
	move_and_slide()
	if current_state != BehaviorMode.FRIGHTENED and velocity > Vector2.ZERO:
		$AnimatedSprite2D.play("default")
		
	check_screen_warp()
	
func chase() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		nav_agent.set_target_position(player.global_position)
	
func check_screen_warp():
	if position.x > screen_size.x:
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
		
func scatter():
	update_scatter_target()
	
func update_scatter_target() -> void:
	nav_agent.set_target_position(Vector2.ZERO)
	
func _on_scatter_timer_timeout():
	if previous_state == BehaviorMode.FRIGHTENED:
		current_state = BehaviorMode.CHASING
	else:
		current_state = previous_state
	
func become_frightened():
	if current_state != BehaviorMode.IDLE:
		enter_frightened.emit()
		current_speed = frightened_speed
		var target_position = position + TILE_SIZE * Vector2(randf_range(10.0, 20.0), randf_range(10.0, 200.0))
		nav_agent.set_target_position(target_position)
		$AnimatedSprite2D.play("frightened")
		var frightened_timer = get_tree().create_timer(7.0)
		frightened_timer.timeout.connect(_on_frightened_timer_timeout)
		await frightened_timer.timeout
		exit_frightened.emit()
		current_speed = regular_speed
	
func _on_frightened_timer_timeout():
	if previous_state == BehaviorMode.CHASING or previous_state == BehaviorMode.IDLE:
		current_state = previous_state
	else: current_state = BehaviorMode.CHASING
	$AnimatedSprite2D.play("default")
		
func get_current_state() -> BehaviorMode:
	return current_state
	
func get_previous_state() -> BehaviorMode:
	return previous_state
	
func set_current_state(state: String) -> void:
	previous_state = current_state
	match state:
		"IDLE":
			current_state = BehaviorMode.IDLE
		"CHASING":
			current_state = BehaviorMode.CHASING
		"SCATTERING":
			current_state = BehaviorMode.SCATTERING
		"FRIGHTENED":
			current_state = BehaviorMode.FRIGHTENED
			
func return_to_start():
	position = start_position
	nav_agent.set_target_position(position)
