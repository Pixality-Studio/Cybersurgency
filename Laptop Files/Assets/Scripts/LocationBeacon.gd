extends Area2D

func _process(delta):
	if Input.is_mouse_button_pressed(2):
		self.position = get_global_mouse_position()
		$Particles2D.emitting == true