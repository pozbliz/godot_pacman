class_name Clyde
extends Ghost


func _ready() -> void:
	super._ready()
	start_position = $ClydeStartPosition.position

func chase() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = (player.position - position) / TILE_SIZE
		if abs(distance.x) + abs(distance.y) > 8:
			nav_agent.set_target_position(player.global_position)
		else:
			current_state = BehaviorMode.SCATTERING
		
func update_scatter_target() -> void:
	nav_agent.set_target_position(Vector2(screen_size.x, screen_size.y))
