extends Node

signal landed(landingVelocity, collider) #player lands after being in the air. Collider is the object it collided with
signal jumped #player has left the ground with upward velocity. currently emitted for flips, too.
signal attack_started
signal attack_finished
signal health_changed(current, max)
signal stamina_changed(current, max, duration)
