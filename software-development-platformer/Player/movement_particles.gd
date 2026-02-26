
extends Node2D
@onready var player: CharacterBody2D = $".."
@onready var leaf_run: GPUParticles2D = $LeafRun
@onready var leaf_jump: GPUParticles2D = $LeafJump
@onready var leaf_land: GPUParticles2D = $LeafLand

#Simple script to enable emmisivity of particles at player's feet when running.
#Made it a separate script to handle different footsteps in different scenes.
var collision

func _ready() -> void:
	GlobalPlayer.jumped.connect(_on_player_jumped)
	GlobalPlayer.landed.connect(_on_player_landed)
	
func _process(_delta: float) -> void:
	collision = player.get_last_slide_collision()
	if player.AnimSprite.animation == "run":
		if collision:
			var collider = collision.get_collider()
			if collider and collider.is_in_group("AutumnLeafMaterial"):
				leaf_run.emitting = true
				leaf_run.process_material.direction.x = -player.velocity.x/40 #pushes particles opposite to direction of motion
	else:
		leaf_run.emitting = false



func _on_player_jumped() -> void:
	collision = player.get_last_slide_collision()
	if collision:
		var collider = collision.get_collider()
		if collider and collider.is_in_group("AutumnLeafMaterial"):
			leaf_jump.process_material.direction.x = -player.velocity.x/50
			leaf_jump.restart()

func _on_player_landed(landVelocity, collider) -> void:
	if collider and collider.is_in_group("AutumnLeafMaterial"):
		if landVelocity.y > 300:
			leaf_land.amount = int(5+landVelocity.y/30)
			leaf_land.process_material.direction.x = player.velocity.x/30
			leaf_land.restart()
