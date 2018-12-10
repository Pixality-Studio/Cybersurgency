extends CanvasLayer

signal resting
signal patching
signal action_type
signal action

var show_ui = false #Whether or not the UI will be visible
var one_shot = false
onready var root = get_node("/root/PlaySpace")

var action_text = {"RestDefault": "REST",
                   "Resting": "RESTING",
                   "Framework": "FRAME\nWORK",
                   "AntiVirus": "ANTI\nVIRUS",
                   "Patching": "PATCHING",
                   "Datamine": "DATA\nMINING",
                   "Disabled": "ACCESS\nDENIED"
                  }

#Determines which progress mode is being used
var progress_mode = {"Protection": true, "AntiVirus": false}
var mouse_control = false

func _process(delta):
	resource_check()
	
	if Input.is_mouse_button_pressed(2) and mouse_control and root.mouse_active:
		if progress_mode.Protection == true:
			progress_mode.Protection = false
			progress_mode.AntiVirus = true
			$InternalButton/InternalLabel.text = action_text.AntiVirus
			root.mouse_active = false
		else:
			progress_mode.Protection = true
			progress_mode.AntiVirus = false
			$InternalButton/InternalLabel.text = action_text.Framework
			root.mouse_active = false

func update_hud(new_maxst, new_st, new_maxpr, new_pr, new_virusprog):
	if progress_mode.Protection == true:
		$InternalProgress.max_value = new_maxpr
		$InternalProgress.value = new_pr
		$InternalProgress.modulate = Color("#FFA336")
	if progress_mode.AntiVirus == true:
		$InternalProgress.max_value = 100
		$InternalProgress.value = new_virusprog
		$InternalProgress.modulate = Color("#FF1515")
	
	$RestActionProgress.max_value = new_maxst #The Rest progress bar max value is set to the Max Stamina
	$RestActionProgress.value = new_st #The Rest progress bar value is set to current Stamina

#When the unpress signal is recieved it unpresses specific buttons
func unpress_button(button1, button2):
	#Button1 = Rest Button
	#Button2 = AntiVirus Button
	
	if button1 == "true" and $RestActionButton.pressed:
		print("Line 32: Unpress Rest")
		$RestActionButton.pressed = false
	
	if button2 == "true" and $InternalButton.pressed:
		print("Line 36: Unpress Anti-Virus")
		$CodeActionButton.pressed = false
		$AntiVirusAction.hide()
		$AntiVirusAction.disabled = true
		$PatchAction.hide()
		$PatchAction.disabled = true
		$AntiVirusAction.disabled = false
		$AntiVirusAction.show()
	one_shot = false

func resource_check():
	if $RestActionProgress.value == 100 and $RestActionButton.pressed:
		$RestActionButton/RestLabel.text = action_text.Disabled
		$RestActionButton.disabled = true
		emit_signal("resting", "false")
		yield(get_tree().create_timer(0.5),"timeout")
		$RestActionButton.disabled = false
		$RestActionButton/RestLabel.text = action_text.RestDefault
		$RestActionButton.pressed = false
		one_shot = false
	
	if $RestActionButton.pressed and $RestActionProgress.value != $RestActionProgress.max_value and one_shot == false:
		emit_signal("patching", "false")
		$RestActionButton/RestLabel.text = action_text.Resting
		$PatchAction.pressed = false
		$AntiVirusAction.pressed = false
		$PatchAction.hide()
		$PatchAction.disabled = true
		$AntiVirusAction.hide()
		$AntiVirusAction.disabled = true
		$CodeActionButton.pressed = false
		$CodeActionButton.disabled = false
		$CodeActionButton.show()
		emit_signal("resting", "true")
		one_shot = true
	if $RestActionButton.pressed and $RestActionProgress.value == $RestActionProgress.max_value:
		$RestActionButton/RestLabel.text = action_text.RestDefault
		emit_signal("resting", "false")
		one_shot = false

func show_ui():
	if show_ui:
		show_ui = false
		$InternalButton.disabled = false
		$InternalButton.show()
		$InternalButton.show()
		$RestActionButton.disabled = false
		$RestActionProgress.show()
		$RestActionButton.show()
		$Inventory.show()
	else:
		show_ui = true
		$InternalButton.disabled = true
		$InternalButton.hide()
		$InternalButton.hide()
		$RestActionButton.disabled = true
		$RestActionProgress.hide()
		$RestActionButton.hide()
		$Inventory.hide()

func _on_RestActionButton_pressed():
	if $RestActionButton.pressed:
		$RestActionButton/RestLabel.text = action_text.Resting
		emit_signal("action", "true", "false", "false", "false")
	else:
		$RestActionButton/RestLabel.text = action_text.RestDefault

func _on_CodeActionButton_pressed():
	if $InternalButton.pressed == false:
		if progress_mode.AntiVirus == true:
			emit_signal("action", "false", "true", "false", "false")
		else:
			emit_signal("action", "false", "false", "true", "false")
		$InternalButton/InternalLabel.text = action_text.Patching
	else:
		if progress_mode.AntiVirus == true:
			$InternalButton/InternalLabel.text = action_text.AntiVirus
		else:
			$InternalButton/InternalLabel.text = action_text.Framework

func _on_AntiVirusActionButton_mouse_entered():
	mouse_control = true
	emit_signal("action_type", 1)

func _on_AntiVirusActionButton_mouse_exited():
	mouse_control = false
	emit_signal("action_type", 0)
