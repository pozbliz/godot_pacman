extends Area2D
class_name Pellet


signal big_pellet_picked_up
signal small_pellet_picked_up


func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if body is Player:
		if is_in_group("big_pellet"):
			big_pellet_picked_up.emit()
		else:
			small_pellet_picked_up.emit()
		queue_free()
