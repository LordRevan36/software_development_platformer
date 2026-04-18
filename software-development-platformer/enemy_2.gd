extends CharacterBody2D

@onready var EnSprite: AnimatedSprite2D = $EnemySprite
@onready var player_char = $"../Player" #CHANGE TO MAIN
@onready var player_cast: RayCast2D = $EnemySprite/PlayerCast
@onready var close_cast: RayCast2D = $EnemySprite/CloseCast
@onready var ground_cast: RayCast2D = $EnemySprite/GroundCast
@onready var timer = $Timer
@onready var right_marker : Marker2D = $EnemySprite/RightMarker
@onready var left_marker : Marker2D = $EnemySprite/LeftMarker

@export var MAX_Health_Enemy := 10
@export var enemy_num := 0

#stuff to determine movement
var direction : Vector2
@onready var right_bound : Vector2 = right_marker.position
@onready var left_bound : Vector2 = left_marker.position
enum State {IDLE, PATROL, CHASE}
var state : State = State.IDLE

#stats
var current_anim
var enemy_name := " "
var gravity_stat
var attack_dmg
var kb_amt
var kb_time
var speed
var acc

#list of all enemy types, use the index value to indicate which enemy to spawn
	#name,  gravity, attack_dmg, kb_amt, kb_time, speed, acc
var enemy_types = [
	["test", 1.0, 10, 500.0, 0.025, 100.0, 50], 
	["ladybug", 1.0, 20, 600, 0.0025, 150.0, 50]
	]

func _ready() -> void:
	_set_stats()

func _physics_process(delta: float) -> void:
	set_movement(delta)
	change_direction()
	look_for_player()

func look_for_player():
	if player_cast.is_colliding():
		var collider = player_cast.get_collider()
		if collider == player_char:
			chase_start()
			print("chasing")
		elif state == State.CHASE:
			chase_stop()
	elif state == State.CHASE:
		chase_stop()

func chase_start() -> void:
	timer.stop()
	state = State.CHASE

func chase_stop() -> void:
	if timer.time_left <= 0:
		timer.start()
		print("start timer")

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	

func set_movement(delta: float) -> void:
	if enemy_num != 1:
		_apply_gravity(delta)
	if state == State.PATROL:
		velocity = velocity.move_toward(direction * speed * (2/3), acc * delta)
	elif state == State.CHASE:
		velocity = velocity.move_toward(direction * speed, acc * delta)
	else:
		velocity = Vector2(0,0)
	
	move_and_slide()

func change_direction() -> void:
	if state == State.PATROL:
		if EnSprite.flip_h:
			#move right
			if self.position.x <= right_bound.x:
				direction = Vector2(1,0)
			else:
				#flip to left
				EnSprite.flip_h = false
				player_cast.target_position = left_bound
		else:
			#moving left
			if self.position.x >= left_bound.x:
				direction = Vector2(-1,0)
			else:
				#flip to right
				EnSprite.flip_h = true
				player_cast.target_position = right_bound
	if state == State.CHASE:
		#follow player
		#does it need to be position or global_position?
		var direction = (player_char.position - position).normalized()
		direction = sign(direction)
		if direction.x == 1:
			#flip right
			EnSprite.flip_h = true
			player_cast.target_position = right_bound
		else:
			#flip left
			EnSprite.flip_h = false
			player_cast.target_position = left_bound


func _update_enemy_animation() -> void:
	if state == State.PATROL:
		current_anim = enemy_name + "_PATROL"
	elif state == State.CHASE:
		current_anim = enemy_name + "_CHASE"
	else:
		current_anim = enemy_name + "_IDLE"


#make it return values later for _assign_stats
	#or just make a lot of class variables
#use a for loop to cycle through enemy array and set variables
#animations
	#have a string with the enemy name and have the parameter be a concatted string
	#standarized animation names where you just have to change the first word(name)
func _set_stats() -> void:
	enemy_name = enemy_types[enemy_num][0]
	gravity_stat = enemy_types[enemy_num][1]
	current_anim = enemy_name + "_IDLE"
	attack_dmg = enemy_types[enemy_num][2]
	kb_amt = enemy_types[enemy_num][3]
	kb_time = enemy_types[enemy_num][4]
	speed = enemy_types[enemy_num][5]
	acc = enemy_types[enemy_num][6]
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player_char: 
		player_char.take_damage(attack_dmg)
		#make it knockback player
		#physics still feel off, needs some tuning
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_knockback(knockback_direction, kb_amt, kb_time)


func _on_timer_timeout() -> void:
	state = State.PATROL
