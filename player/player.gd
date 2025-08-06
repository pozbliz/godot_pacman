extends CharacterBody2D
class_name Player


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


const SPEED = 50.0

var tile_size = 16
var direction: Vector2 = Vector2.ZERO


signal player_hit


func _ready() -> void:
	hide()

func _physics_process(delta: float) -> void:
	velocity = direction * SPEED
	if velocity > Vector2.ZERO:
		$AnimatedSprite2D.play("default")
		$AnimatedSprite2D.rotation = direction.angle()
	move_and_slide()
	
func _unhandled_input(_event: InputEvent) -> void:
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
	direction = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", false)
