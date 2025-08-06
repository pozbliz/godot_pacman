extends CharacterBody2D
class_name Ghost


enum BehaviorMode { CHASING, SCATTERING }

const SPEED = 40.0

var screen_size: Vector2
var direction: Vector2 = Vector2.ZERO
var current_state: BehaviorMode = BehaviorMode.CHASING


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	hide()
	screen_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	velocity = direction * SPEED
	if velocity > Vector2.ZERO:
		$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.rotation = direction.angle()
	move_and_slide()
	check_screen_warp()
	
func check_screen_warp():
	if position.x > screen_size.x:
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
		
func scatter():
	pass
