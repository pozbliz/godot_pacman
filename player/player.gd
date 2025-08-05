extends CharacterBody2D
class_name Player


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


const SPEED = 50.0

var tile_size = 16
var direction: Vector2 = Vector2.ZERO
var next_direction: Vector2 = Vector2.ZERO
var shape_query = PhysicsShapeQueryParameters2D.new()


signal player_hit

func _ready() -> void:
	hide()
	shape_query.shape = collision_shape_2d.shape
	shape_query.collision_mask = 1 << 2

func _physics_process(delta: float) -> void:
	if direction == Vector2.ZERO:
		direction = next_direction
	if can_turn(next_direction, delta):
		direction = next_direction
	elif not can_turn(direction, delta):
		direction = Vector2.ZERO
	
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.rotation = direction.angle()
	
	velocity = direction * SPEED
	move_and_slide()
	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_left"):
		next_direction = Vector2.LEFT
	if Input.is_action_just_pressed("move_right"):
		next_direction = Vector2.RIGHT
	if Input.is_action_just_pressed("move_up"):
		next_direction = Vector2.UP
	if Input.is_action_just_pressed("move_down"):
		next_direction = Vector2.DOWN
		
func can_turn(dir: Vector2, delta) -> bool:
	shape_query.transform = global_transform.translated(dir * SPEED * delta * 2)
	shape_query.exclude = [self] 
	var result = get_world_2d().direct_space_state.intersect_shape(shape_query)
	return result.size() == 0
	
func reset_player():
	show()
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	next_direction = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", false)
