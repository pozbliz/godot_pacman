extends HBoxContainer

var heart_full = preload("res://assets/lives_icon.png")

func _ready() -> void:
	hide()

func update_health(value):
	update_simple(value)
	
func update_simple(value):
	for i in get_child_count():
		get_child(i).visible = value > i
