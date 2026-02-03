# https://www.youtube.com/watch?v=9AcqlKawwQY
extends Area2D
@onready var transition_time: Timer = $TransitionTime

@export_file("*.tscn") var exit
@export var spawn_position: Vector2

var player


func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		player = body
		body.velocity.x = sign(body.velocity.x)*body.SPEED
		body.state = Player.State.EXIT
		transition_time.start()
		
	


func _on_transition_time_timeout() -> void:
	get_tree().change_scene_to_file(exit)
	player.state = Player.State.IDLE
	player.position = spawn_position
