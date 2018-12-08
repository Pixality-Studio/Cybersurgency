extends CanvasLayer

signal resting
signal patching

var show_ui = false #Whether or not the UI will be visible
var one_shot = false

var action_text = {"RestDefault": "REST",
                   "Resting": "RESTING",
                   "CodeDefault": "CODE",
                   "AntiVirus": "ANTI-VIRUS",
                   "Patching": "PATCHING",
                   "Datamine": "DATA MINING",
                   "Disabled": "ACCESS\nDENIED"
                  }

func _process(delta):
	resource_check()

func update_hud(new_maxst, new_st, new_maxpr, new_pr, new_virusprog):
	$RestActionProgress.max_value = new_maxst
	$RestActionProgress.value = new_st
	$PatchProgress.max_value = new_maxpr
	$PatchProgress.value = new_pr
	$CodeActionProgress.value = new_virusprog

func unpress_button(value):
	if value == "true" and $RestActionButton.pressed:
		print("unpressed")
		$RestActionButton.pressed = false
	if value == "true" and $CodeActionButton.pressed:
		print("unpressed")
		$CodeActionButton.pressed = false
		$AntiVirusAction.hide()
		$AntiVirusAction.disabled = true
		$PatchAction.hide()
		$PatchAction.disabled = true
		$CodeActionButton.disabled = false
		$CodeActionButton.show()
	if value == "true" and $PatchAction.pressed or $AntiVirusAction.pressed:
		print("unpressed")
		$PatchAction.pressed = false
		$PatchAction.hide()
		$AntiVirusAction.pressed = false
		$AntiVirusAction.disabled = true
		$AntiVirusAction.hide()
		$PatchAction.disabled = true
		$CodeActionButton.disabled = false
		$CodeActionButton.show()
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
		
	if $PatchAction.pressed and one_shot == false:
		$AntiVirusAction.hide()
		$AntiVirusAction.disabled = true
		$PatchAction.hide()
		$PatchAction.disabled = true
		$PatchProgress.show()
		emit_signal("patching", "true")
		one_shot = true
	if $PatchAction.pressed and $PatchProgress.value == $PatchProgress.max_value:
		$PatchProgress.hide()
		$PatchAction.disabled = false
		$PatchAction.show()
		$AntiVirusAction.disabled = false
		$AntiVirusAction.show()
		one_shot = false

func show_ui():
	print("Signal Received: Show UI")
	if show_ui:
		show_ui = false
		$CodeActionButton.disabled = false
		$RestActionButton.disabled = false
		$RestActionProgress.show()
		$RestActionButton.show()
		$CodeActionProgress.show()
		$CodeActionButton.show()
	else:
		show_ui = true
		$RestActionProgress.hide()
		$RestActionButton.hide()
		$RestActionButton.disabled = true
		$CodeActionProgress.hide()
		$CodeActionButton.hide()
		$CodeActionButton.disabled = true

func _on_CodeActionButton_pressed():
	emit_signal("resting", "false")
	$RestActionButton.pressed = false
	$RestActionButton/RestLabel.text = action_text.RestDefault
	$CodeActionButton.hide()
	$CodeActionButton.disabled = true
	$AntiVirusAction.disabled = false
	$PatchAction.disabled = false
	$AntiVirusAction.show()
	$PatchAction.show()
