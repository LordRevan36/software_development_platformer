extends CharacterBody2D
@onready var AnimSprite: AnimatedSprite2D = $PlayerSprite #just makes code look better, easier to change later if file paths change
@onready var Slash: AnimatedSprite2D = $Slash

#if you ever want to do this, drag in the node you're referencing, then hold command/ctrl while releasing

const SPEED = 288.0
const JUMP_VELOCITY = -500.0
var activeAction = false #variable for when player shouldn't be able to do other things, like when attacking or flipping
var tempYVelocityStorage = 0
var facing = 1 #1 for right, -1 for left
var hardLand = false #used to do landing animation after a large fall, but not tiny gaps

func _physics_process(delta: float) -> void:
	if (AnimSprite.animation == "attack") or (AnimSprite.animation == "backflip") or (AnimSprite.animation == "frontflip")  or (AnimSprite.animation == "crouch") or (AnimSprite.animation == "land"):
		activeAction = true
	else:
		activeAction = false
			
	
	# Add the gravity.
	if not is_on_floor():
		if AnimSprite.animation == "attack":
			velocity += get_gravity() * delta / 2
		else:
			velocity += get_gravity() * delta

	# Handles jumps and flips. THIS IS VERY LARGE SORRY. kinda spaghetty
	if is_on_floor() and !activeAction:
		if Input.is_action_just_pressed("Up"):
			velocity.x /= 2
			AnimSprite.play("crouch")
			await AnimSprite.animation_finished
			velocity.y = JUMP_VELOCITY
			AnimSprite.play("jump")
			await AnimSprite.animation_finished
			hardLand = true
			AnimSprite.play("fall")
		if Input.is_action_just_pressed("FlipLeft"):
			velocity.x /= 2
			AnimSprite.play("crouch")
			await AnimSprite.animation_finished
			if facing == 1:
				velocity.y = JUMP_VELOCITY*1.3
				velocity.x = -SPEED
				AnimSprite.play("backflip")
				await AnimSprite.animation_finished
				hardLand = true
				AnimSprite.play("fall")
			elif facing == -1:
				velocity.y = JUMP_VELOCITY*0.8
				velocity.x = -SPEED*1.8
				AnimSprite.play("frontflip")
				await AnimSprite.animation_finished
				hardLand = true
				AnimSprite.play("fall")
		elif Input.is_action_just_pressed("FlipRight"):
			velocity.x /= 2
			AnimSprite.play("crouch")
			await AnimSprite.animation_finished
			if facing == -1:
				velocity.y = JUMP_VELOCITY*1.3
				velocity.x = SPEED
				AnimSprite.play("backflip")
				await AnimSprite.animation_finished
				hardLand = true
				AnimSprite.play("fall")
			elif facing == 1:
				velocity.y = JUMP_VELOCITY*0.8
				velocity.x = SPEED*1.8
				AnimSprite.play("frontflip")
				await AnimSprite.animation_finished
				hardLand = true
				AnimSprite.play("fall")

	# Get the input direction and handle the movement/deceleration.
	if !activeAction:
		var direction := Input.get_axis("Left", "Right")
		if !is_on_floor():
			velocity.x *= 0.99
		elif direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED/2)
		
	#making attack slow you in air
	if AnimSprite.animation == "attack":
		tempYVelocityStorage = velocity.y * 0.99
		velocity.y /= 2
		move_and_slide()
		velocity.y = tempYVelocityStorage
	else:
		move_and_slide()
		
	
	#Animations
	#Checks first to see if you are attacking
	if Input.is_action_just_pressed("Attack 1") and AnimSprite.animation != "attack":
		velocity.x /= 2
		if facing > 0:
			Slash.flip_h = false
			Slash.position = Vector2(120,40)
		else:
			Slash.flip_h = true
			Slash.position = Vector2(-120,40)
		AnimSprite.play("attack")
		Slash.show()
		Slash.play("slash")
		await Slash.animation_finished
		Slash.hide()
		await AnimSprite.animation_finished
		if !is_on_floor():
			AnimSprite.play("fall")
		else:
			AnimSprite.play("idle")
		#if not it allows for other animations to play
	if !activeAction and is_on_floor():
		if Input.is_action_pressed("Right"):
			AnimSprite.flip_h = false
			facing = 1
			AnimSprite.play("run")
		elif Input.is_action_pressed("Left"):
			AnimSprite.flip_h = true
			facing = -1
			AnimSprite.play("run")
		elif hardLand:
			AnimSprite.play("land")
			await AnimSprite.animation_finished
			hardLand = false
			AnimSprite.play("idle")
		else:
			AnimSprite.play("idle")
