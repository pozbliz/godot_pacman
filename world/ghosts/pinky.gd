class_name Pinky
extends Ghost


const TILES_AHEAD: int = 4


func _ready() -> void:
	super._ready()
	start_position = $PinkyStartPosition.position

func chase() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var ahead_offset = player.direction.normalized() * TILE_SIZE * TILES_AHEAD
		var target_pos = player.global_position + ahead_offset
		nav_agent.set_target_position(target_pos)
		
func update_scatter_target() -> void:
	nav_agent.set_target_position(Vector2(screen_size.x, 0))
