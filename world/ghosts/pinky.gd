class_name Pinky
extends Ghost


const TILES_AHEAD: int = 4
const DOT_LIMIT: int = 30


func _ready() -> void:
	super._ready()
	start_position = $PinkyStartPosition.position

func update_chase_target() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var ahead_offset = player.direction.normalized() * TILE_SIZE * TILES_AHEAD
		var target_pos = player.global_position + ahead_offset
		nav_agent.set_target_position(target_pos)
