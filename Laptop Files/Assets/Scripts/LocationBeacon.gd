extends Area2D

signal beacon_location
signal beacon_enter

func _process(delta):
	if Input.is_mouse_button_pressed(2):
		self. position = get_global_mouse_position()
		emit_signal("beacon_location", self)
		emit_signal("beacon_enter")