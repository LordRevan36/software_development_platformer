extends CharacterBody2D
class_name Player

@onready var AnimSprite: AnimatedSprite2D = $PlayerSprite #just makes code look better, easier to change later if file paths change
@onready var AreaHitbox: Area2D = $AreaHitbox #secondary hitbox for checking collisions with Area2D's
@onready var Slash: AnimatedSprite2D = $Slash
@onready var CoyoteTimer: Timer = $Timers/CoyoteJumpTimer
@onready var AttackTimer: Timer = $Timers/AttackTimer #making these timers both for balance tweaking, and not letting animations determinephysics state
@onready var ManaTimer: Timer = $Timers/ManaTimer
@onready var SkillTimer: Timer = $UI/SkillTree/SkillTimer
@onready var ManaAttackTimer: Timer = $Timers/ManaAttackTimer
#if you ever want to do this, drag in the node you're referencing, then hold command/ctrl while releasing

const SPEED = 300.0
const JUMP_VELOCITY = -510.0
const ATTACK_SLOW_RATE = 0.5 #multiplier to slow down player velocity when they attack
const Dodgeball = preload("res://Player/dodgeball.tscn") #scene for the fireball attack

@export var default_friction = 0.9 #value from 0 to 1. 1 means full friction on floor when running, 0 means full icy floor
@export var air_control = 0.5 #value from 0 to 1, lets you control how easily player can control their air movement

#can reference State outside of player as Player.State.IDLE (or other value)
enum State {IDLE, EXIT, ATTACK, BACKFLIP, FRONTFLIP, FLIPLAND, LAND, RUN, FALL, JUMP, CROUCH}
var was_on_floor = false #stores last frame's is_on_floor for detecting landing.
var direction = 0
var facing = 1 #1 for right, -1 for left. like direction, but doesnt change if we dont want it to
var state : State = State.IDLE #state variable so physics doesn't depend on animations (bad practice i think?)
var time := 0.0 #time
var crouchStartTime := 0.0 #used to store how long player crouches down for
var jumpVelocity = Vector2(0,0) #stores velocity of player immediately after jumping
var landVelocity = Vector2(0,0) #stores velocity of player immediately before landing
var slow = 1 #stores slowdown rate during things like attack
var canJump = true #used to let player jump a little after leaving the platform
var Mana = GlobalPlayer.mana #stores the mana for the player
var usingBouncePad = false #used to prevent _land function if player is using the bounce pad
var health = GlobalPlayer.health #stores the health for the player
var friction = 0.9
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
#var duration = 0

#signals can be put here but typically should be put in global_player so that they are easier to detect.

func _ready() -> void:
	friction = default_friction

func _physics_process(delta: float) -> void:
	#immediate escape if exiting to another scene
	if state == State.EXIT:
		move_and_slide()
		return
	
	#update variables
	direction = Input.get_axis("Left", "Right") # =-1 when holding left, 1 when holding right, 0 when neither
	time += delta #used to calculate time the jump button is held
	slow = 1 #reset to 1 until changed later by attack etc. 
	velocity += _return_gravity(delta) #add gravity with diff. multipliers based on state
	
	#update signals and states
	if is_on_floor() and !was_on_floor:
		if not usingBouncePad:
			_land()
	if Input.is_action_just_pressed("Attack"):
		_attack()
	_update_direction()
	if is_on_floor():
		_floor_update() #handles logic for coyote, horizontal velocity, and state update
	if canJump: #Doesn't require is_on_floor(), so they can coyote jump
		_jump_check() #checks for crouch state and activates jump if conditions met
	if not is_on_floor(): #not on floor, its a little inefficient to not connect this to the is_on_floor above, but thats not how the order worked out
		_not_on_floor_update() #handles coyote timer start, updates for fall state, handles jump midair movement
	#store variables for next frame
	was_on_floor = is_on_floor() #value used isn subsequent frame to see if player just landed
	landVelocity = velocity #stores velocity from last frame so landing velocity is accurate
	
	if state == State.ATTACK: #slow movement if attacking
		slow = 0.5 #used to slow player's velocity right before calculations for effects
	_slowed_move() #runs move_and_slide() using slow value stored
	
	updateAnimations()
	
	#checking for opening other menus
	_menu_checks()
	
	#knockback
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
			
	if Input.is_action_just_pressed("Dodgeball") and ManaAttackTimer.is_stopped():
		_mana_attack_1()

#returns gravity vector adjusted based on state
func _return_gravity(delta: float) -> Vector2:
	#something suggested online for better gamefeel- increase gravity when falling. i think it feels nice
	if state == State.ATTACK:
		return get_gravity() * delta * 0.6
	elif velocity.y > 0:
		return get_gravity() * delta * 1.3
	return get_gravity() * delta

#handles signal and updates state when landing
func _land() -> void:
	GlobalPlayer.landed.emit(landVelocity, get_last_slide_collision().get_collider()) #emit signal for platforms etc.
	if state == State.BACKFLIP or state == State.FRONTFLIP: #diff type of land for flips
		state = State.FLIPLAND
	else:
		state = State.LAND
	if get_last_slide_collision().get_collider().is_in_group("Platform"):
		friction = get_last_slide_collision().get_collider().friction
		print(friction)

#handles signal and updates state when attacking
func _attack() -> void:
	state = State.ATTACK
	GlobalPlayer.attack_started.emit()
	AttackTimer.start()

#updates direction
func _update_direction() -> void:
	if [State.RUN, State.IDLE, State.FALL, State.JUMP].has(state):
		if Input.is_action_pressed("Right"):
			facing = 1
		elif Input.is_action_pressed("Left"):
			facing = -1

#handles logic for coyote, horizontal velocity, and state update
func _floor_update() -> void:
	#resetting coyote jump time
	if !canJump:
		canJump = true
		
	# MOVEMENT ON GROUND, includes friction and slight sliding on landing. values will likely need to be tweaked later
	match(state):
		State.CROUCH:
			velocity.x = move_toward(velocity.x, 0, SPEED/24*friction)
			#slow = (0.8-(time-crouchStartTime)*1.5)/friction #slows movement if holding jumps
		State.RUN:
			velocity.x = move_toward(velocity.x, SPEED * direction, SPEED/4*friction)
		State.IDLE, State.LAND:
			velocity.x = move_toward(velocity.x, SPEED * direction, SPEED/8*friction)
		State.FLIPLAND:
			velocity.x = move_toward(velocity.x, SPEED * direction, SPEED/32*friction)
	
	# sees if on ground and not currently crouched or otherwise occupied
	if not [State.CROUCH, State.ATTACK, State.FLIPLAND].has(state):
		if direction != 0 and !is_on_wall():
			state = State.RUN
		elif state != State.LAND: #this way, you can still run after landing, which feels better
			state = State.IDLE

#checks for crouch state and activates jump if conditions met
func _jump_check() -> void:
	if not [State.CROUCH, State.ATTACK].has(state):
		#always allow regular jump; require skill unlock for frontflip/backflip
		if (Input.is_action_just_pressed("Up") or (((Input.is_action_just_pressed("Frontflip") and GlobalControls.canFrontflip) or (Input.is_action_just_pressed("Backflip")) and GlobalControls.canBackflip))):
			state = State.CROUCH
			crouchStartTime = time
	if (state == State.CROUCH): #if holding jump:
		#if player has held down the jump/flip button too long (forces jump without key release):
		if ((time-crouchStartTime)>0.5):
			if Input.is_action_pressed("Up"):
				jump(Vector2.ZERO)
			elif Input.is_action_pressed("Backflip") and GlobalControls.canBackflip:
				backflip()
			elif Input.is_action_pressed("Frontflip") and GlobalControls.canFrontflip:
				frontflip()
		#regular jump/flip detection (waits for key release)
		if Input.is_action_just_released("Up"):
			jump(Vector2.ZERO)
		elif Input.is_action_just_released("Backflip") and GlobalControls.canBackflip:
			backflip()
		elif Input.is_action_just_released("Frontflip") and GlobalControls.canFrontflip:
			frontflip()

func jump(input_velocity : Vector2):
	if (input_velocity == Vector2.ZERO):
		velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/2)
	else:
		velocity = input_velocity
	state = State.JUMP
	canJump = false
	GlobalPlayer.jumped.emit()
	jumpVelocity = velocity

func backflip():
	velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/4)*1.4
	velocity.x = -(SPEED+SPEED*(time-crouchStartTime)/4)*facing*0.5
	state = State.BACKFLIP
	canJump = false
	GlobalPlayer.jumped.emit()
	jumpVelocity = velocity

func frontflip():
	velocity.y = (JUMP_VELOCITY+JUMP_VELOCITY*(time-crouchStartTime)/4)*0.7
	velocity.x = (SPEED+SPEED*(time-crouchStartTime)/4)*facing*1.8
	state = State.FRONTFLIP
	canJump = false
	GlobalPlayer.jumped.emit()
	jumpVelocity = velocity

#handles coyote timer start, updates for fall state, handles jump midair movement
func _not_on_floor_update() -> void:
	if canJump and CoyoteTimer.is_stopped():
		CoyoteTimer.start()
	friction = default_friction
	#SETS FALLING IF IN AIR AND NOT DOING OTHER ACTION
	if not [State.JUMP, State.BACKFLIP, State.FRONTFLIP, State.ATTACK].has(state) and not (state == State.CROUCH and canJump):
		state = State.FALL
	#MIDAIR MOVEMENT. not during flips though! To nerf  them
	if [State.JUMP, State.FALL].has(state):
		if sign(-direction) == sign(velocity.x) or abs(SPEED*direction) > abs(velocity.x): #so you keep inertia midair if not trying to move
			velocity.x = lerp(velocity.x, SPEED*direction, 0.2*air_control)
		else: #so if you're not trying to slow down, you won't.
			velocity.x = lerp(velocity.x, SPEED*direction, 0.01*air_control)
	if state == State.BACKFLIP or state == State.FRONTFLIP:
		velocity.x = lerp(velocity.x, jumpVelocity.x, 0.02) #so bumping a wall doesnt fully stop momentum

#runs move_and_slide() using slow value stored
func _slowed_move() -> void:
	velocity *= slow
	move_and_slide()
	velocity /= slow

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


func _menu_checks() -> void:
	#checks for pause input then updates level tree
	if Input.is_action_just_released("Pause"):
		$UI/PauseMenu.show()
		
	#checks for opening the skill tree tab, then updates level tree
	if Input.is_action_just_released("Skills"):
		$UI/SkillTree.show()
		SkillTimer.start()
	
	#pauses the game when either menu is visible
	if $UI/PauseMenu.visible or $UI/SkillTree.visible:
		get_tree().paused = true
	else:
		get_tree().paused = false

#UI FUNCTIONS
#function for taking damage
func take_damage(amount: int) -> void:
	GlobalPlayer.health = max(GlobalPlayer.health - amount, 0)
	GlobalPlayer.health_changed.emit(GlobalPlayer.health, GlobalPlayer.MAX_Health)
	if GlobalPlayer.health < 0:
		GlobalPlayer.health = 0

#function for healing
func heal(amount: int) -> void:
	GlobalPlayer.health = max(GlobalPlayer.health + amount, 0)
	GlobalPlayer.health_changed.emit(GlobalPlayer.health, GlobalPlayer.MAX_Health)
	if GlobalPlayer.health > GlobalPlayer.MAX_Health:
		GlobalPlayer.health = GlobalPlayer.MAX_Health

#adds/substracts value to mana
func update_mana(amount: int, duration: float) -> void:
	Mana = max(Mana + amount, 0)
	GlobalPlayer.mana_changed.emit(Mana, GlobalPlayer.MAX_Mana, duration) #changes value on UI
	if Mana > GlobalPlayer.MAX_Mana:
		Mana = GlobalPlayer.MAX_Mana
	if Mana < 0:
		Mana = 0
	ManaTimer.start()

#triggers full regen of mana
func regenMana() -> void:
	#adds mana back in increments of 10 over 0.15sec until at max
	update_mana(10, 0.75)
	while Mana != GlobalPlayer.MAX_Mana:
		update_mana(10, 0.75)

#apply knockback when hit by an enemy
func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration

#CONNECTED FUNCTIONS
func _on_coyote_jump_timer_timeout() -> void:
	canJump = false
	if state == State.CROUCH: #makes player jump instead of just falling off the ledge if they were trying to jump
		if Input.is_action_pressed("Up"):
			jump(Vector2.ZERO)
		elif Input.is_action_pressed("Backflip"):
			backflip()
		elif Input.is_action_pressed("Frontflip"):
			frontflip()

func _on_attack_timer_timeout() -> void:
	state = State.IDLE
	GlobalPlayer.attack_finished.emit()

func _on_slash_animation_finished() -> void: #used to visually hide slash when its done
	Slash.hide()

func _on_mana_timer_timeout() -> void:
	regenMana()

#Checks for a bouncepad entered
func _on_area_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("BouncePad"):
		usingBouncePad = true #prevents _land() from running
		jump(area._return_new_player_velocity(velocity)) #forces jump from bouncepad

#checks for a bouncepad exited
func _on_area_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("BouncePad"):
		usingBouncePad = false #allows landing again


func _on_damage_button_pressed() -> void:
	take_damage(10)
	update_mana(-10, 0.15)
	ManaTimer.start()

func _on_heal_button_pressed() -> void:
	heal(10)
	update_mana(10,0.15)

func _mana_attack_1() -> void:
	if Mana >= 50:
		if ManaAttackTimer.is_stopped():
			var projectile = Dodgeball.instantiate()
			projectile.direction = facing
			projectile.position = position
			get_parent().add_child(projectile)
			update_mana(-50, 0.25)
			ManaAttackTimer.start()
