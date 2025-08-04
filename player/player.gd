extends CharacterBody2D
class_name Player


@onready var ray_main = $RayCast2D
@onready var ray_offset1: RayCast2D = $RayOffset_1
@onready var ray_offset2: RayCast2D = $RayOffset_2

const SPEED = 200.0

var tile_size = 64
var direction: Vector2 = Vector2.ZERO
var next_direction: Vector2 = Vector2.ZERO

signal player_hit

func _ready() -> void:
	hide()
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size / 2

func _physics_process(delta: float) -> void:
	if is_on_tile_center() or direction == Vector2.ZERO:
		if can_turn(next_direction):
			direction = next_direction
			print("can turn: ", next_direction)
		elif not can_turn(direction):
			print("cannot turn")
			direction = Vector2.ZERO
	
	velocity = direction * SPEED
	
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.rotation = direction.angle()
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		position = position.snapped(Vector2.ONE * tile_size) + Vector2.ONE * tile_size / 2
		velocity = Vector2.ZERO
		if collision.get_collider() is Ghost:
			player_hit.emit()
			
func is_on_tile_center() -> bool:
	var local_pos = (position - Vector2.ONE * tile_size / 2)
	print("local pos: ", local_pos)
	print("position :", position)
	return (int(local_pos.x) % tile_size == 0) and (int(local_pos.y) % tile_size == 0)
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_left"):
		next_direction = Vector2.LEFT
	if Input.is_action_just_pressed("move_right"):
		next_direction = Vector2.RIGHT
	if Input.is_action_just_pressed("move_up"):
		next_direction = Vector2.UP
	if Input.is_action_just_pressed("move_down"):
		next_direction = Vector2.DOWN
		
func can_turn(dir: Vector2) -> bool:
	if dir == Vector2.ZERO:
		return false
	
	ray_main.target_position = dir * (tile_size / 4)
	ray_offset1.target_position = dir * (tile_size / 4)
	ray_offset2.target_position = dir * (tile_size / 4)
	
	var offset = dir.orthogonal() * 4
	ray_offset1.position = offset
	ray_offset2.position = -offset
	ray_main.position = Vector2.ZERO
	
	ray_main.force_raycast_update()
	ray_offset1.force_raycast_update()
	ray_offset2.force_raycast_update()

	return not (ray_main.is_colliding() or ray_offset1.is_colliding() or ray_offset2.is_colliding())
	
func reset_player():
	show()
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	next_direction = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", false)
