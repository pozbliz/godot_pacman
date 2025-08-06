extends CharacterBody2D
class_name Ghost


enum BehaviorMode { IDLE, CHASING, SCATTERING }

const SPEED = 40.0

var screen_size: Vector2
var direction: Vector2 = Vector2.ZERO
var current_state: BehaviorMode = BehaviorMode.IDLE


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	hide()
	screen_size = get_viewport_rect().size
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	if current_state == BehaviorMode.IDLE:
		direction = Vector2.ZERO
	else:
		velocity = direction * SPEED
		if velocity > Vector2.ZERO:
			$AnimatedSprite2D.play("default")
		$AnimatedSprite2D.rotation = direction.angle()
		move_and_slide()
		check_screen_warp()
		if current_state == BehaviorMode.SCATTERING:
			scatter()
		
	
func check_screen_warp():
	if position.x > screen_size.x:
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
		
func scatter():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		direction = (player.position - position).normalized() * -1
		
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
