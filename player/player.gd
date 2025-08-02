extends CharacterBody2D
class_name Player


const SPEED = 200.0

var direction: Vector2 = Vector2.ZERO

signal player_died


func _ready() -> void:
	hide()

func _physics_process(delta: float) -> void:
	velocity = direction * SPEED
	
	move_and_slide()
	
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
	
