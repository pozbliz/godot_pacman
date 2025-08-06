extends Ghost

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	custom_ai_behavior(delta)

func custom_ai_behavior(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		direction = (player.position - position).normalized()
