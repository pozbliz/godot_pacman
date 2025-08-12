class_name Inky
extends Ghost

const TILES_AHEAD: int = 2


func _ready() -> void:
	super._ready()
	start_position = $InkyStartPosition.position

func update_chase_target() -> void:
	# Draw line from Blinky’s position to two tiles in front of Pac-Man, 
	# then double the length of the line
	var player = get_tree().get_first_node_in_group("player")
	var blinky = get_tree().get_first_node_in_group("blinky")
	if player and blinky:
		var ahead_offset = player.direction.normalized() * TILE_SIZE * TILES_AHEAD
		var target_player_pos = player.global_position + ahead_offset
		var blinky_to_target_player_pos = target_player_pos - blinky.global_position
		var target_pos = blinky.global_position + 2 * blinky_to_target_player_pos
		
		nav_agent.set_target_position(target_pos)

func update_scatter_target() -> void:
	nav_agent.set_target_position(Vector2(0, screen_size.y))
