#Script for bouncy Area2Ds.
#Simply attach to the area2D you want the player to bounce over.

extends Area2D

func _ready():
	if !body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.velocity.y > 0:
		body.bounceBody(Vector2(body.velocity.x,-body.velocity.y-100))
