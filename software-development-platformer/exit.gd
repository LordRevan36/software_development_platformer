# https://www.youtube.com/watch?v=9AcqlKawwQY
extends Area2D

@export_file("*.tscn") var exit
@export var spawn_position: Vector2


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file(exit)
		body.position = spawn_position
