
extends Node2D
@onready var player: CharacterBody2D = $".."
@onready var run_particle: GPUParticles2D = $RunParticle
@onready var jump_particle: GPUParticles2D = $JumpParticle
@onready var land_particle: GPUParticles2D = $LandParticle

#Simple script to enable emmisivity of particles at player's feet when running.
#Made it a separate script to handle different footsteps in different scenes.

func _process(_delta: float) -> void:
	if player.AnimSprite.animation == "run":
		run_particle.emitting = true
		run_particle.process_material.direction.x = -player.velocity.x/40 #pushes particles opposite to direction of motion
	else:
		run_particle.emitting = false


func _on_player_jumped() -> void:
	jump_particle.process_material.direction.x = -player.velocity.x/50
	jump_particle.restart()

func _on_player_landed() -> void:
	land_particle.amount = int(15+player.velocity.y/50) #BROKEN RN. landing velocity is always recorded the same because ground slows player.
	land_particle.restart()
