extends CharacterBody2D
@onready var AnimSprite: AnimatedSprite2D = $PlayerSprite #just makes code look better, easier to change later if file paths change
@onready var Slash: AnimatedSprite2D = $Slash
@onready var CoyoteTimer: Timer = $CoyoteJumpTimer

#if you ever want to do this, drag in the node you're referencing, then hold command/ctrl while releasing

const SPEED = 288.0
const JUMP_VELOCITY = -520.0

@export var friction = 0.9 #value from 0 to 1. 1 means full friction on floor when running, 0 means full icy floor
@export var air_control = 0.5 #value from 0 to 1, lets you control how easily player can control their air movement
@export var MAX_Health := 100

var was_on_floor = false #replaces old hardLand; simply stores last frame's is_on_floor for detecting landing.
var direction = 0
var facing = 1 #1 for right, -1 for left. like direction, but doesnt change if we dont want it to
var state = "idle" #state variable so physics doesn't depend on animations (bad practice i think?)
var time := 0.0 #time
var crouchStartTime := 0.0 #used to store how long player crouches down for
var jumpVelocity = Vector2(0,0) #stores velocity of player immediately after jumping
var landVelocity = Vector2(0,0) #stores velocity of player immediately before landing
var slow = 1 #stores velocity vector of player immediately before attacking
var canJump = true #used to let player jump a little after leaving the platform
#Healthbar
var health := MAX_Health

 #signals to communicate important events, can be detected in other scripts.
#Currently just used for particles and physics.
signal landed #player lands after being in the air
signal jumped #player has left the ground with upward velocity. currently emitted for flips, too.
signal attack_started
signal attack_finished
signal health_changed(current, max)

#function for taking damage
func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	emit_signal("health_changed", health, MAX_Health)
	if health < 0:
		health = 0

#function for healing
func heal(amount: int) -> void:
	health = max(health + amount, 0)
	emit_signal("health_changed", health, MAX_Health)
	if health > MAX_Health:
		health = MAX_Health



#Healthbar
signal health_changed(current, max)
@export var MAX_Health := 100
var health := MAX_Health

#function for taking damage
func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	emit_signal("health_changed", health, MAX_Health)
	if health < 0:
		health = 0

#function for healing
func heal(amount: int) -> void:
	health = max(health + amount, 0)
	emit_signal("health_changed", health, MAX_Health)
	if health > MAX_Health:
		health = MAX_Health

func _physics_process(delta: float) -> void:
	direction = Input.get_axis("Left", "Right") # =-1 when holding left, 1 when holding right, 0 when neither
	time += delta
	slow = 1
	
	
	#something suggested online for better gamefeel- increase falling gravity
	if state == "attack":
		velocity += get_gravity() * delta * 0.6
	elif velocity.y > 0:
		velocity += get_gravity() * delta * 1.3
	else:
		velocity += get_gravity() * delta
		
	# LANDING
	if is_on_floor() and !was_on_floor:
		landed.emit()
		if state == "backflip" or state == "frontflip":
			state = "flipland"
		else:
			state = "land"
			
			
	# ATTACKING
	if Input.is_action_just_pressed("Attack 1"):
		state = "attack"
		attack_started.emit()
	
	#UPDATES FACING WHEN IN APPROPRIATE STATE
	if state == "run" or state == "idle" or state == "fall" or state == "jump":
		if Input.is_action_pressed("Right"):
			facing = 1;
		elif Input.is_action_pressed("Left"):
			facing = -1;
			
			
	if is_on_floor():
		
		#resetting coyote jump time
		if !canJump:
			canJump = true
			
		# MOVEMENT ON GROUND, includes friction and slight sliding on landing. values will likely need to be tweaked later
		if (state == "crouch"):
			slow = (0.8-(time-crouchStartTime)*1.5)/friction #slows movement if holding jumps
		elif state == "run":
			velocity.x = move_toward(velocity.x, SPEED * direction, SPEED/4*friction)
		elif state == "idle" or state == "land":
			velocity.x = move_toward(velocity.x, SPEED * direction, SPEED/8*friction)
		elif state == "flipland":
			velocity.x = move_toward(velocity.x, SPEED * direction, SPEED/32*friction)
			
		# sees if on ground and not currently crouched or otherwise occupied
		if state != "crouch" and state != "attack" and state != "flipland":
			if direction != 0:
				state = "run"
			elif state != "land": #this way, you can still run after landing, which feels better
				state = "idle"
				
	# CROUCHING DOWN (i didn't use is_on_floor() in this section, so they can coyote jump
	if canJump:
		if state != "crouch" and state != "attack":
			if (Input.is_action_just_pressed("Up") or Input.is_action_just_pressed("FlipLeft") or Input.is_action_just_pressed("FlipRight")):
				state = "crouch"
				crouchStartTime = time
			
		# HOLDING JUMP/FLIP
		if (state == "crouch"):
			slow = (0.8-(time-crouchStartTime)*1.5)/friction #slows movement if holding jumps

			#JUMPING/FLIPPING
			if ((time-crouchStartTime)>0.5): #if player's held down the jump/flip button too long:
				if Input.is_action_pressed("Up"):
					jump()
				elif Input.is_action_pressed("FlipLeft"):
					if facing == 1:
						backflip()
					else:
						frontflip()
				elif Input.is_action_pressed("FlipRight"):
					if facing == 1:
						frontflip()
					else:
						backflip()
			#regular jump/flip detection
			if Input.is_action_just_released("Up"):
				jump()
			elif Input.is_action_just_released("FlipLeft"):
				if facing == 1:
					backflip()
				else:
					frontflip()
			elif Input.is_action_just_released("FlipRight"):
				if facing == 1:
					frontflip()
				else:
					backflip()
		
		
	if !is_on_floor(): #not on floor, its a little inefficient to not connect this to the is_on_floor above, but thats nit how the order worked out
		if canJump and CoyoteTimer.is_stopped():
			CoyoteTimer.start()

		#SETS FALLING IF IN AIR AND NOT DOING OTHER ACTION
		if (state != "jump") and (state != "backflip") and (state != "frontflip") and (state != "attack") and !(state == "crouch" and canJump):
			state = "fall"
		#MIDAIR MOVEMENT. not during flips though! To nerf  them
		if state == "jump" or state == "fall":
			velocity.x = lerp(velocity.x, SPEED*direction, 0.2*air_control)
		if state == "backflip" or state == "frontflip":
			velocity.x = lerp(velocity.x, jumpVelocity.x, 0.02) #so bumping a wall doesnt fully stop momentum
		
		
		
	was_on_floor = is_on_floor()	 #value used isn subsequent frame to see if player just landed
	
	if state == "attack":
		slow = 0.5 #used to slow player's velocity right before calculations for effects
	velocity *= slow
	move_and_slide()
	velocity /= slow
	updateAnimations()



func updateAnimations():
	if facing == 1:
		AnimSprite.flip_h = false;
	else:
		AnimSprite.flip_h = true;
	if state == "crouch":
		AnimSprite.play("crouch")
	elif state == "idle":
		AnimSprite.play("idle")
	elif state == "run":
		AnimSprite.play("run")
	elif state == "jump":
		AnimSprite.play("jump")
		await AnimSprite.animation_finished
		state = "fall" ##THIS IS A BAD SOLUTION BUT I STRUGGLE TO FIND A WORKAROUND. Ideally, updateAnimations wouldn't affect any physics processes at all! 
	elif state == "backflip":
		AnimSprite.play("backflip")
		#await AnimSprite.animation_finished
		#state = "fall"
	elif state == "frontflip":
		AnimSprite.play("frontflip")
		#await AnimSprite.animation_finished
		#state = "fall"
	elif state == "fall":
		AnimSprite.play("fall")
	elif state == "attack":
		AnimSprite.play("attack")
		await AnimSprite.animation_finished
		if AnimSprite.animation == "attack": #prevents waiting for ANY animation to end if this one is interrupted
			state = "idle" #AGAIN I DONT LIKE DOING THIS. Could create a timer and set the state in physics_process, but im too lazy rn.
		attack_finished.emit()
	elif state == "land":
		AnimSprite.play("land")
		await AnimSprite.animation_finished
		if AnimSprite.animation == "land":
			state = "idle"
	elif state == "flipland":
		AnimSprite.play("flipland")
		await AnimSprite.animation_finished
		if AnimSprite.animation == "flipland":
			state = "idle"
			
func jump():
	velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/2)
	state = "jump"
	canJump = false
	jumped.emit()
	jumpVelocity = velocity
	
	
func backflip():
	velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/4)*1.45
	velocity.x = -(SPEED+SPEED*(time-crouchStartTime)/4)*facing*0.6
	state = "backflip"
	canJump = false
	jumped.emit()
	jumpVelocity = velocity
	
	
func frontflip():
	velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/4)*0.8
	velocity.x = (SPEED+SPEED*(time-crouchStartTime)/4)*facing*1.7
	state = "frontflip"
	canJump = false
	jumped.emit()
	jumpVelocity = velocity
	


func _on_coyote_jump_timer_timeout() -> void:
	canJump = false
