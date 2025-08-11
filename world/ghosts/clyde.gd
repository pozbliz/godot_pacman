class_name Clyde
extends Ghost


func _ready() -> void:
	super._ready()
	start_position = $ClydeStartPosition.position

func update_chase_target() -> void:
	# TODO implement Clyde logic
	var player = get_tree().get_first_node_in_group("player")
	if player:
		direction = (player.position - position).normalized()
		
func update_scatter_target() -> void:
	nav_agent.set_target_position(Vector2(screen_size.x, screen_size.y))
