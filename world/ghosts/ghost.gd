extends CharacterBody2D
class_name Ghost


const SPEED = 40.0

var direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	hide()

func _physics_process(delta: float) -> void:
	velocity = direction * SPEED
	if velocity > Vector2.ZERO:
		$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.rotation = direction.angle()
	move_and_slide()
