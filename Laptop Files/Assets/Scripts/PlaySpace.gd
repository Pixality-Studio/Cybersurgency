extends Node

var can_zoom_in = true
var can_zoom_out = true

#0 = Movement | 1 = Interact
var action_type = 0
var mouse_active = true
var one_shot = true

func _process(delta):
	check_camera()
	if mouse_active == false and one_shot:
		$MouseActive.start()
		one_shot = false

func check_camera():
	if Input.is_action_just_pressed("scroll_down") and can_zoom_out:
		$Character/Camera2D.zoom += Vector2(0.2, 0.2)
		$PersonalHud.scale -= Vector2(0.5, 0.5)
		$PersonalHud/RestActionProgress.rect_position += Vector2(8,0)
		$PersonalHud/RestActionButton.rect_position += Vector2(8,0)
		$PersonalHud/CodeActionProgress.rect_position += Vector2(8,0)
		$PersonalHud/CodeActionButton.rect_position += Vector2(8,0)
		$PersonalHud/AntiVirusAction.rect_position += Vector2(8,0)
		$PersonalHud/PatchAction.rect_position += Vector2(8,0)
		print($PersonalHud.scale)
	if Input.is_action_just_pressed("scroll_up") and can_zoom_in:
		$Character/Camera2D.zoom -= Vector2(0.2, 0.2)
		$PersonalHud.scale += Vector2(0.5, 0.5)
		$PersonalHud/RestActionProgress.rect_position += Vector2(-8,0)
		$PersonalHud/RestActionButton.rect_position += Vector2(-8,0)
		$PersonalHud/CodeActionProgress.rect_position += Vector2(-8,0)
		$PersonalHud/CodeActionButton.rect_position += Vector2(-8,0)
		$PersonalHud/AntiVirusAction.rect_position += Vector2(-8,0)
		$PersonalHud/PatchAction.rect_position += Vector2(-8,0)
		print($PersonalHud.scale)
	
	if $PersonalHud.scale == Vector2(4 , 4):
		can_zoom_in = false
	else:
		can_zoom_in = true
	if $PersonalHud.scale == Vector2(2, 2):
		can_zoom_out = false
	else:
		can_zoom_out = true

func mouse_command(type):
	if type == 0:
		action_type = 0
	else:
		action_type = 1
	print(action_type)

func _on_MouseActive_timeout():
	mouse_active = true
