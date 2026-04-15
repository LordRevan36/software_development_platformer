extends Node

signal landed(landingVelocity, collider) #player lands after being in the air. Collider is the object it collided with
signal jumped #player has left the ground with upward velocity. currently emitted for flips, too.
signal attack_started
signal attack_finished
signal health_changed(current, max)
signal mana_changed(current, max, duration)

@export var MAX_Health := 100
@export var MAX_Mana := 100
var health = MAX_Health
var mana = MAX_Mana
var Attack : int = 1
var can_continue_atk
var can_continue_hp
var can_continue_mana

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
