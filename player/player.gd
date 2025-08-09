extends CharacterBody2D
class_name Player



const SPEED = 50.0

var direction: Vector2 = Vector2.ZERO
var screen_size: Vector2


signal player_hit


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	hide()
	screen_size = get_viewport_rect().size
	add_to_group("player")
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	velocity = direction * SPEED
	if velocity > Vector2.ZERO:
		$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.rotation = direction.angle()
	move_and_slide()
	check_screen_warp()
	
func _unhandled_input(_event: InputEvent) -> void:
	if get_tree().paused:
		return
	if Input.is_action_just_pressed("move_left"):
		direction = Vector2.LEFT
	if Input.is_action_just_pressed("move_right"):
		direction = Vector2.RIGHT
	if Input.is_action_just_pressed("move_up"):
		direction = Vector2.UP
	if Input.is_action_just_pressed("move_down"):
		direction = Vector2.DOWN
		
func check_screen_warp():
	if position.x > screen_size.x:
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
		
func _on_hitbox_body_entered(body: Node):
	if body.is_in_group("enemy"):
		player_hit.emit(body)
	
func reset_player():
	show()
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	$WallsHitbox.set_deferred("disabled", false)
