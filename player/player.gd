extends CharacterBody2D
class_name Player


const SPEED = 200.0

var direction: Vector2 = Vector2.ZERO

signal player_hit

func _ready() -> void:
	hide()

func _physics_process(delta: float) -> void:
	velocity = direction * SPEED
	if velocity > Vector2.ZERO:
		$AnimatedSprite2D.play("default")
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider() is Ghost:
			player_hit.emit()
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_left"):
		direction = Vector2.LEFT
	if Input.is_action_just_pressed("move_right"):
		direction = Vector2.RIGHT
	if Input.is_action_just_pressed("move_up"):
		direction = Vector2.UP
	if Input.is_action_just_pressed("move_down"):
		direction = Vector2.DOWN
	
func reset_player():
	show()
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", false)
	
	
