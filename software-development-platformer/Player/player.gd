extends CharacterBody2D
class_name Player

@onready var AnimSprite: AnimatedSprite2D = $PlayerSprite #just makes code look better, easier to change later if file paths change
@onready var Slash: AnimatedSprite2D = $Slash
@onready var CoyoteTimer: Timer = $Timers/CoyoteJumpTimer
@onready var AttackTimer: Timer = $Timers/AttackTimer #making these timers both for balance tweaking, and not letting animations determinephysics state
@onready var StaminaTimer: Timer = $Timers/StaminaTimer
#i added a comment to see if 4.6 works
#if you ever want to do this, drag in the node you're referencing, then hold command/ctrl while releasing

const SPEED = 300.0
const JUMP_VELOCITY = -510.0
const JUMP_COST = 10 #stamina cost of actions, so we can change later
const FLIP_COST = 30

@export var friction = 0.9 #value from 0 to 1. 1 means full friction on floor when running, 0 means full icy floor
@export var air_control = 0.5 #value from 0 to 1, lets you control how easily player can control their air movement
@export var MAX_Health := 100
@export var MAX_Stamina := 100 

#can reference State outside of player as Player.State.IDLE (or other value)
enum State {IDLE, EXIT, ATTACK, BACKFLIP, FRONTFLIP, FLIPLAND, LAND, RUN, FALL, JUMP, CROUCH}
var was_on_floor = false #replaces old hardLand; simply stores last frame's is_on_floor for detecting landing.
var direction = 0
var facing = 1 #1 for right, -1 for left. like direction, but doesnt change if we dont want it to
var state : State = State.IDLE #state variable so physics doesn't depend on animations (bad practice i think?)
var time := 0.0 #time
var crouchStartTime := 0.0 #used to store how long player crouches down for
var jumpVelocity = Vector2(0,0) #stores velocity of player immediately after jumping
var landVelocity = Vector2(0,0) #stores velocity of player immediately before landing
var slow = 1 #stores velocity vector of player immediately before attacking
var canJump = true #used to let player jump a little after leaving the platform
var health := MAX_Health #stores the health for the player
var stamina := MAX_Stamina #stores the stamina for the player
#var duration = 0
var exercise = false

#signals to communicate important events, can be detected in other scripts.
#Currently just used for particles and physics.
#signal jumped #player has left the ground with upward velocity. currently emitted for flips, too.
#signal attack_started
#signal attack_finished
#signal health_changed(current, max)
#signal stamina_changed(current, max, duration)

#function for taking damage
func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	GlobalPlayer.health_changed.emit(health, MAX_Health)
	if health < 0:
		health = 0

#function for healing
func heal(amount: int) -> void:
	health = max(health + amount, 0)
	GlobalPlayer.health_changed.emit(health, MAX_Health)
	if health > MAX_Health:
		health = MAX_Health

#function for stamina
func stam(amount: int, duration: float) -> void:
	exercise = true
	stamina = max(stamina + amount, 0)
	GlobalPlayer.stamina_changed.emit(stamina, MAX_Stamina, duration)
	if stamina > MAX_Stamina:
		stamina = MAX_Stamina
	if stamina < 0:
		stamina = 0
		
func regenStam() -> void:
	stam(10,0.75)
	while stamina != MAX_Stamina:
			stam(10, 0.75)

func _physics_process(delta: float) -> void:
	if state == State.EXIT:
		move_and_slide()
		return
		
	direction = Input.get_axis("Left", "Right") # =-1 when holding left, 1 when holding right, 0 when neither
	time += delta #used to calculate time the jump button is held
	slow = 1
	
	
	#gravity
	#something suggested online for better gamefeel- increase gravity when falling. i think it feels nice
	if state == State.ATTACK:
		velocity += get_gravity() * delta * 0.6
	elif velocity.y > 0:
		velocity += get_gravity() * delta * 1.3
	else:
		velocity += get_gravity() * delta
		
	# LANDING
	if is_on_floor() and !was_on_floor:
		GlobalPlayer.landed.emit(landVelocity, get_last_slide_collision().get_collider())
		print(get_last_slide_collision().get_collider())
		if state == State.BACKFLIP or state == State.FRONTFLIP:
			state = State.FLIPLAND
		else:
			state = State.LAND
			
			
	# ATTACKING
	if Input.is_action_just_pressed("Attack 1"):
		state = State.ATTACK
		GlobalPlayer.attack_started.emit()
		AttackTimer.start()
		
	
	#UPDATES FACING WHEN IN APPROPRIATE STATE
	if state == State.RUN or state == State.IDLE or state == State.FALL or state == State.JUMP:
		if Input.is_action_pressed("Right"):
			facing = 1;
		elif Input.is_action_pressed("Left"):
			facing = -1;
			
			
	if is_on_floor():
		
		#resetting coyote jump time
		if !canJump:
			canJump = true
			
		# MOVEMENT ON GROUND, includes friction and slight sliding on landing. values will likely need to be tweaked later
		if (state == State.CROUCH):
			velocity.x = move_toward(velocity.x, 0, SPEED/24*friction)
			#slow = (0.8-(time-crouchStartTime)*1.5)/friction #slows movement if holding jumps
		elif state == State.RUN:
			velocity.x = move_toward(velocity.x, SPEED * direction, SPEED/4*friction)
		elif state == State.IDLE or state == State.LAND:
			velocity.x = move_toward(velocity.x, SPEED * direction, SPEED/8*friction)
		elif state == State.FLIPLAND:
			velocity.x = move_toward(velocity.x, SPEED * direction, SPEED/32*friction)
		# sees if on ground and not currently crouched or otherwise occupied
		if state != State.CROUCH and state != State.ATTACK and state != State.FLIPLAND:
			if direction != 0 and !is_on_wall():
				state = State.RUN
			elif state != State.LAND: #this way, you can still run after landing, which feels better
				state = State.IDLE
	# CROUCHING DOWN (i didn't use is_on_floor() in this section, so they can coyote jump
	if canJump:
		if state != State.CROUCH and state != State.ATTACK:
			if ((Input.is_action_just_pressed("Up") and stamina >= JUMP_COST) or ((Input.is_action_just_pressed("FlipLeft") or Input.is_action_just_pressed("FlipRight")) and stamina >= FLIP_COST)):
				state = State.CROUCH
				crouchStartTime = time
			
		# HOLDING JUMP/FLIP
		if (state == State.CROUCH):
			
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
		if (state != State.JUMP) and (state != State.BACKFLIP) and (state != State.FRONTFLIP) and (state != State.ATTACK) and !(state == State.CROUCH and canJump):
			state = State.FALL
		#MIDAIR MOVEMENT. not during flips though! To nerf  them
		if state == State.JUMP or state == State.FALL:
			if sign(-direction) == sign(velocity.x) or abs(SPEED*direction) > abs(velocity.x): #so you keep inertia midair if not trying to move
				velocity.x = lerp(velocity.x, SPEED*direction, 0.2*air_control)
			else: #so if you're not trying to slow down, you won't.
				velocity.x = lerp(velocity.x, SPEED*direction, 0.01*air_control)
		if state == State.BACKFLIP or state == State.FRONTFLIP:
			velocity.x = lerp(velocity.x, jumpVelocity.x, 0.02) #so bumping a wall doesnt fully stop momentum
		
		
		
	was_on_floor = is_on_floor()	 #value used isn subsequent frame to see if player just landed
	landVelocity = velocity #stores velocity from last frame so landing velocity is accurate
	
	if state == State.ATTACK:
		slow = 0.5 #used to slow player's velocity right before calculations for effects
	velocity *= slow
	move_and_slide()
	
	velocity /= slow
	updateAnimations()
	
	if state == State.IDLE:
		exercise = false



func updateAnimations():
	if facing == 1:
		AnimSprite.flip_h = false;
	else:
		AnimSprite.flip_h = true;
	if state == State.CROUCH:
		AnimSprite.play("crouch")
	elif state == State.IDLE:
		AnimSprite.play("idle")
	elif state == State.RUN:
		AnimSprite.play("run")
	elif state == State.JUMP:
		AnimSprite.play("jump")
		await AnimSprite.animation_finished
		state = State.FALL ##THIS IS A BAD SOLUTION BUT I STRUGGLE TO FIND A WORKAROUND. Ideally, updateAnimations wouldn't affect any physics processes at all! 
	elif state == State.BACKFLIP:
		AnimSprite.play("backflip")
		#await AnimSprite.animation_finished
		#state = "fall"
	elif state == State.FRONTFLIP:
		AnimSprite.play("frontflip")
		#await AnimSprite.animation_finished
		#state = "fall"
	elif state == State.FALL:
		if velocity.y < 100: #if payer's velocity is upwards, hair won't fall yet
			AnimSprite.animation = "fall"
			AnimSprite.frame = 0
		else:
			AnimSprite.play("fall")
	elif state == State.ATTACK:
		AnimSprite.play("attack")
		if facing == 1:
			Slash.position = Vector2(95,46)
			Slash.flip_h = false
		else:
			Slash.position = Vector2(-95,46)
			Slash.flip_h = true
		if AnimSprite.animation == "attack" and AnimSprite.frame == 2: #delays the slash slightly
			Slash.show()
			Slash.play()
	elif state == State.LAND:
		AnimSprite.play("land")
		await AnimSprite.animation_finished
		if AnimSprite.animation == "land":
			state = State.IDLE
	elif state == State.FLIPLAND:
		AnimSprite.play("flipland")
		await AnimSprite.animation_finished
		if AnimSprite.animation == "flipland":
			state = State.IDLE
	elif state == State.EXIT:
		AnimSprite.play("run")
	if state == State.IDLE:
		exercise = false

func jump():
	velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/2)
	state = State.JUMP
	canJump = false
	GlobalPlayer.jumped.emit()
	jumpVelocity = velocity
	stam(-JUMP_COST, 0.3)
	StaminaTimer.start()
	
	
func backflip():
	velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/4)*1.4
	velocity.x = -(SPEED+SPEED*(time-crouchStartTime)/4)*facing*0.5
	state = State.BACKFLIP
	canJump = false
	GlobalPlayer.jumped.emit()
	jumpVelocity = velocity
	stam(-FLIP_COST, 0.3)
	StaminaTimer.start()
	
func frontflip():
	velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/4)*0.7
	velocity.x = (SPEED+SPEED*(time-crouchStartTime)/4)*facing*1.8
	state = State.FRONTFLIP
	canJump = false
	GlobalPlayer.jumped.emit()
	jumpVelocity = velocity
	stam(-FLIP_COST, 0.3)
	StaminaTimer.start()


func _on_coyote_jump_timer_timeout() -> void:
	canJump = false
	if state == State.CROUCH: #makes player jump instead of just falling off the ledge if they were trying to jump
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


func _on_attack_timer_timeout() -> void:
	state = State.IDLE
	GlobalPlayer.attack_finished.emit()

# HIDING SLASH
func _on_slash_animation_finished() -> void: #used to visually hide slash when its done
	Slash.hide()

func _on_stamina_timer_timeout() -> void:
	state = State.IDLE
	regenStam()
