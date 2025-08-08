extends Ghost


func _ready() -> void:
	super._ready()

func update_chase_target() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		direction = (player.position - position).normalized()
