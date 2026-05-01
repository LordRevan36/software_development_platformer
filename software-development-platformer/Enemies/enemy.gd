extends RigidBody2D
class_name enemy
@onready var EnSprite: AnimatedSprite2D = $EnemySprite
@export var MAX_Health_Enemy := 10
@onready var player_char : Player = $"../Player" #CHANGE TO MAIN
#list of all enemy types, use the index value to indicate which enemy to spawn
	#name,  gravity, attack_dmg, kb_amt, kb_time, speed
var enemy_types = [
	["test", 1.0, 10, 500.0, 0.025, 35], 
	["ladybug", 1.0, 20, 600, 0.0025, 0]
	]

@export var enemy_num := 0
var velocity := linear_velocity.x
enum State {IDLE, PATROL, CHASE}
var state : State = State.IDLE
var current_anim
var enemy_name := " "
var gravity_stat
var attack_dmg
var kb_amt
var kb_time
var speed

@onready var AnimSprite: AnimatedSprite2D = $EnemySprite #just makes code look better, easier to change later if file paths change

#use for basic motion and stats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("start")
	_set_stats()
	_apply_stats(gravity_stat)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var direction = (player_char.global_position - global_position).normalized()
	if enemy_num == 1:
		#$EnemySprite.look_at(player_char.global_position)
			linear_velocity = lerp(linear_velocity, direction * speed, 8.5 * delta)
	if enemy_num == 0:
		if  direction.x > 0:
			velocity = speed
		else:
			velocity = -speed
		#linear_velocity =
		
	

func _apply_stats(gravity: float) -> void:
	set_gravity_scale(gravity)
	
	

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
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player_char: 
		player_char.take_damage(attack_dmg)
		#make it knockback player
		#physics still feel off, needs some tuning
		var player_kb_direction = (body.global_position - global_position)
		body.apply_knockback(player_kb_direction.normalized(), kb_amt, kb_time)
		apply_central_force(player_kb_direction)
		
		
