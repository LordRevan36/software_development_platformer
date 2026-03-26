extends RigidBody2D
class_name enemy
@onready var EnSprite: AnimatedSprite2D = $EnemySprite
@export var MAX_Health_Enemy := 10
#list of all enemy types, use the index value to indicate which enemy to spawn
	#name,  gravity, move_speed, attack_dmg 
var enemy_types = [
	["test", 1.0], 
	["ladybug", 0.0]
	]

@export var enemy_num := 0
var current_anim
var enemy_name := " "
var gravity_stat

@onready var AnimSprite: AnimatedSprite2D = $EnemySprite #just makes code look better, easier to change later if file paths change

#use for basic motion and stats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_stats()
	_apply_stats(gravity_stat)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _apply_stats(gravity: float) -> void:
	set_gravity_scale(gravity)
	

func _update_enemy_animation() -> void:
	pass
#make it return values later for _assign_stats
	#or just make a lot of class variables
#use a for loop to cycle through enemy array and set variables
#animations
	#have a string with the enemy name and have the parameter be a concatted string
	#standarized animation names where you just have to change the first word(name)
func _set_stats() -> void:
	enemy_name = enemy_types[enemy_num][0]
	gravity_stat = enemy_types[enemy_num][1]
	current_anim = enemy_name + "_idle"
	#enemy_name = enemy_types[enemy_num]
	#if enemy_num == 0:
	#	gravity_stat = 1.0
	#if enemy_num == 1:
	#	gravity_stat = 0
