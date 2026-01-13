extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	$Slash.hide()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Up") and is_on_floor():
		$AnimatedSprite2D.play("backflip")
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	#Animations
	#Checks first to see if you are attacking
	if Input.is_action_just_pressed("Attack 1"):
		$AnimatedSprite2D.play("attack")
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D.play("idle")
		#if not it allows for other animations to play
	if $AnimatedSprite2D.animation != "attack" and is_on_floor():
		if Input.is_action_pressed("Right"):
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("run")
		elif Input.is_action_pressed("Left"):
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("idle")
	if $AnimatedSprite2D.animation == "attack":
		$Slash.show()
