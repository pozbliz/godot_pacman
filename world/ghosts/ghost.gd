extends CharacterBody2D
class_name Ghost


enum BehaviorMode { IDLE, CHASING, SCATTERING, FRIGHTENED }

@onready var nav_agent := $NavigationAgent2D

const SPEED = 37.5
const TILE_SIZE: int = 16


var screen_size: Vector2
var direction: Vector2 = Vector2.ZERO
var current_state: BehaviorMode = BehaviorMode.IDLE
var start_position: Vector2

signal enter_frightened
signal exit_frightened


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	hide()
	screen_size = get_viewport_rect().size
	add_to_group("enemy")
	$AnimatedSprite2D.play("default")
	
	# Navigation Agent
	nav_agent.process_mode = Node.PROCESS_MODE_PAUSABLE
	nav_agent.target_desired_distance = 1.0
	nav_agent.path_desired_distance = 3.0

func _physics_process(delta: float) -> void:
	match current_state:
		BehaviorMode.IDLE:
			direction = Vector2.ZERO
			velocity = Vector2.ZERO
		BehaviorMode.SCATTERING:
			update_scatter_target()
		BehaviorMode.CHASING:
			update_chase_target()
		BehaviorMode.FRIGHTENED:
			update_frightened_target()
	
	if not nav_agent.is_navigation_finished():
		var next_point = nav_agent.get_next_path_position()
		direction = (next_point - global_position).normalized()
	else:
		direction = Vector2.ZERO
	
	velocity = direction * SPEED
	move_and_slide()
	if current_state != BehaviorMode.FRIGHTENED and velocity > Vector2.ZERO:
		$AnimatedSprite2D.play("default")
		
	check_screen_warp()
	
func update_chase_target() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		nav_agent.set_target_position(player.global_position)

func update_scatter_target() -> void:
	#nav_agent.set_target_position(Vector2.ZERO)
	pass
	
func update_frightened_target() -> void:
	var target_position = position + Vector2(randf_range(100.0, 300.0), randf_range(100.0, 300.0))
	nav_agent.set_target_position(target_position)
		
func check_screen_warp():
	if position.x > screen_size.x:
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
		
func scatter():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		direction = (player.position - position).normalized() * -1
		
func become_frightened():
	if current_state == BehaviorMode.CHASING:
		enter_frightened.emit()
		set_current_state("FRIGHTENED")
		$AnimatedSprite2D.play("frightened")
		var frightened_timer = get_tree().create_timer(7.0)
		frightened_timer.timeout.connect(_on_frightened_timer_timeout)
		await frightened_timer.timeout
		exit_frightened.emit()
	
func _on_frightened_timer_timeout():
	set_current_state("CHASING")
	$AnimatedSprite2D.play("default")
		
func get_current_state() -> BehaviorMode:
	return current_state
	
func set_current_state(state: String) -> void:
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
