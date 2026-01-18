extends CharacterBody2D
@onready var AnimSprite: AnimatedSprite2D = $PlayerSprite #just makes code look better, easier to change later if file paths change
@onready var Slash: AnimatedSprite2D = $Slash
#if you ever want to do this, drag in the node you're referencing, then hold command/ctrl while releasing

const SPEED = 288.0
const JUMP_VELOCITY = -520.0
var was_on_floor = false #replaces old hardLand; simply stores last frame's is_on_floor for detecting landing.
var direction = 0
var facing = 1 #1 for right, -1 for left. like direction, but doesnt change if we dont want it to
var state = "idle" #state variable so physics doesn't depend on animations (bad practice i think?)

var time := 0.0 #time
var crouchStartTime := 0.0 #used to store how long player crouches down for
var jumpVelocity = Vector2(0,0) #stores x velocity of player immediately after jumping
var slow = 1 #stores velocity vector of player immediately before attacking


 #signals to communicate important events, can be detected in other scripts.
#Currently just used for particles and physics.
signal landed #player lands after being in the air
signal jumped #player has left the ground with upward velocity. currently emitted for flips, too.
signal attack_started
signal attack_finished

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

		# run
		velocity.x = move_toward(velocity.x, SPEED * direction, SPEED/4)
		
		# sees if on ground and not currently crouched or otherwise occupied
		if state != "crouch" and state != "attack":
			if direction != 0:
				state = "run"
			elif state != "land": #this way, you can still run after landing, which feels better
				state = "idle"
			if (Input.is_action_just_pressed("Up") or Input.is_action_just_pressed("FlipLeft") or Input.is_action_just_pressed("FlipRight")):
				state = "crouch"
				crouchStartTime = time
		
		# HOLDING JUMP/FLIP
		if (state == "crouch"):
			slow = 1-(time-crouchStartTime)*1.5 #slows movement if holding jumps

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
		
			
	else: #not on floor
		#SETS FALLING IF IN AIR AND Not OTHER ACTION
		if (state != "jump") and (state != "backflip") and (state != "frontflip") and (state != "attack"):
			state = "fall"
		#MIDAIR MOVEMENT. not during flips though
		if state == "jump" or state == "fall":
			velocity.x = lerp(velocity.x, SPEED*direction, 0.2)
			
			
			
			
	#LANDING
	if is_on_floor() and !was_on_floor:
		landed.emit()
		state = "land"
		
	was_on_floor = is_on_floor()	 #value used in subsequent frame to see if player just landed
	
	if state == "attack":
		slow = 0.5 #used to slow player's velocity for effects
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
		await AnimSprite.animation_finished
		state = "fall"
	elif state == "frontflip":
		AnimSprite.play("frontflip")
		await AnimSprite.animation_finished
		state = "fall"
	elif state == "fall":
		AnimSprite.play("fall")
	elif state == "attack":
		AnimSprite.play("attack")
		await AnimSprite.animation_finished
		state = "idle" #AGAIN I DONT LIKE DOING THIS. Could create a timer and set the state in physics_process, but im too lazy rn.
		attack_finished.emit()
	elif state == "land":
		AnimSprite.play("land")
		await AnimSprite.animation_finished
		state = "idle"
		
func jump():
	velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/2)
	state = "jump"
	jumped.emit()
	jumpVelocity = velocity
	
	
func backflip():
	velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/4)*1.45
	velocity.x = -(SPEED+SPEED*(time-crouchStartTime)/4)*facing*0.6
	state = "backflip"
	jumped.emit()
	jumpVelocity = velocity
	
	
func frontflip():
	velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/4)*0.8
	velocity.x = (SPEED+SPEED*(time-crouchStartTime)/4)*facing*1.7
	state = "frontflip"
	jumped.emit()
	jumpVelocity = velocity
	
