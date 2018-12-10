extends KinematicBody2D

signal hud_update
signal show_ui
signal unpress

#Holds states for the character
enum {IDLE, RESTING, MOVING, CODING, HURT, DEAD}
var state #Current character state

var target = self.position
onready var root = get_node("/root/PlaySpace")

#Holds all the stats for the character
var stats = {"MoveSpeed": 5.0, #How fast does the character move
             "Velocity": Vector2(0,0), #What's the current velocity of the character
             "NeededVel": Vector2(0,0),
             "Distance": 0.0,
             "StaminaMax": 100.0, #How much stamina the character can have
             "StaminaLeft": 100.0, #How much stamina the character has left
             "ProtectionMax": 100.0, #How much protection the character can have
             "ProtectionLeft": 100.0, #How much protection the character has left
             "AntiVirusProg": 0.0,
             "CodeSpeed": 0.0, #How fast the character can code
             "CodePower": 0.0 #How effective your code is
            }

func _ready():
	change_state(IDLE)
	emit_signal("hud_update", stats.StaminaMax, stats.StaminaLeft, stats.ProtectionMax, stats.ProtectionLeft, stats.AntiVirusProg)

func _physics_process(delta):
	if state != IDLE:
		stats.StaminaLeft -= 0.01
	emit_signal("hud_update", stats.StaminaMax, stats.StaminaLeft, stats.ProtectionMax, stats.ProtectionLeft, stats.AntiVirusProg)
	check_input()
	
	stats.Velocity = target - self.position  # gets the direction the npc is facing
	stats.NeededVel = sqrt(stats.Velocity.x * stats.Velocity.x + stats.Velocity.y * stats.Velocity.y)  # calculates how far away player is
	if stats.NeededVel >= stats.Distance:  # determines if npc should move
		stats.NeededVel = sqrt(stats.Velocity.x * stats.Velocity.x + stats.Velocity.y * stats.Velocity.y)
	move_and_slide(stats.Velocity, Vector2(0,0))

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			stats.Velocity = Vector2(0,0)
		RESTING:
			$ProtectionReplenish.stop()
			emit_signal("unpress", "false", "true")
		MOVING:
			emit_signal("unpress", "true", "true")
		CODING:
			emit_signal("unpress", "true", "false")
		HURT:
			$RestReplenish.stop()
			if stats.ProtectionLeft >= 0:
				change_state(DEAD)
		DEAD:
			print("Game Over")

func check_input():
	var one_shot = false #For timers that require to be one shot so they don't constantly restart
	
	var test = Input.is_action_just_pressed("test")
	var action_ui = Input.is_action_just_pressed("show_actions")
	var move = Input.is_mouse_button_pressed(2)
	
	if state == IDLE:
		stats.Velocity = Vector2(0,0)
	
	if move and root.action_type == 0:
		target = get_global_mouse_position()
		change_state(MOVING)
	
	if stats.Velocity != Vector2(0,0):
		change_state(MOVING)
	
	if action_ui:
		emit_signal("show_ui")

func check_action(resting, anti_virus, framework, data_mine):
	if resting == true:
		$RestReplenish.start()
		$ProtectionReplenish.stop()
		change_state(RESTING)
	else:
		$RestReplenish.stop()
		change_state(IDLE)
	
	if anti_virus == true:
		$AntiVirusProg.start()
		$RestReplenish.stop()
		change_state(CODING)
	else:
		$ProtectionReplenish.stop()
		change_state(IDLE)
	
	if framework == true:
		$ProtectionReplenish.start()
		$RestReplenish.stop()
		change_state(CODING)
	else:
		$ProtectionReplenish.stop()
		change_state(IDLE)

#When resting handles giving back Stamina
func _on_RestReplenish_timeout():
	stats.StaminaLeft += 0.5
	$RestReplenish.start()
	if stats.StaminaLeft > stats.StaminaMax:
		stats.StaminaLeft = stats.StaminaMax
		$RestReplenish.stop()
		change_state(IDLE)

func _on_ProtectionReplenish_timeout():
	stats.ProtectionLeft += 0.5
	$ProtectionReplenish.start()
	if stats.ProtectionLeft > stats.ProtectionMax:
		stats.ProtectionLeft = stats.ProtectionMax
		$ProtectionReplenish.stop()
		change_state(IDLE)

func _on_LocationBeacon_body_entered(body):
	change_state(IDLE)
	print("Target reached")