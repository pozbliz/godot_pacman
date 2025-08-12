class_name Blinky
extends Ghost


func _ready():
	super._ready()
	start_position = $BlinkyStartPosition.position
	add_to_group("blinky")
	
func update_scatter_target() -> void:
	nav_agent.set_target_position(Vector2.ZERO)
