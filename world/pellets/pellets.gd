class_name Pellet
extends Area2D


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
		elif is_in_group("small_pellet"):
			small_pellet_picked_up.emit()
		queue_free()
