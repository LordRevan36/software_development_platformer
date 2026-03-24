extends Area2D

@onready var collision_shape = $CollisionShape2D
@onready var sprite_2d = $Sprite2D

@export var JUMP_MULTIPLIER : float = 1.3
@export var JUMP_MAXIMUM : float = 750.0
@export var JUMP_MINIMUM : float = 510.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _return_new_player_velocity(p_velocity: Vector2) -> Vector2:
	var normal_vector : Vector2 = Vector2(0,1).rotated(rotation) #grab normal vector of platform
	print("Normal vector: " + str(normal_vector))
	var orthogonal_vector = normal_vector.orthogonal() #grab perpendicular vector for "project" later
	print("orthogonal vector: " + str(orthogonal_vector))
	if normal_vector.y * p_velocity.y < 0: #if they were traveling down into the platform, make them travel up
		p_velocity.reflect(orthogonal_vector)
	print("p velocity: " + str(p_velocity))
	var ortho_velocity : Vector2 = p_velocity.project(orthogonal_vector) #component of velocity traveling along platform
	print("ortho velocity: " + str(ortho_velocity))
	var normal_velocity : Vector2 = p_velocity.project(normal_vector) #component of velocity traveling perpendicular to platform
	print("Normal velocity: " + str(normal_velocity))
	normal_velocity *= JUMP_MULTIPLIER #scale perp. velocity with the jump boost multiplier of the bounce pad
	print("Normal velocity: " + str(normal_velocity))
	var normal_length = normal_velocity.length()
	print("Normal length: " + str(normal_length))
	normal_velocity = normal_velocity.normalized()
	normal_velocity *= min(max(normal_length, JUMP_MINIMUM), JUMP_MAXIMUM) #keep jump in range
	print("Normal velocity: " + str(normal_velocity))
	var final_velocity = normal_velocity + ortho_velocity #add components back together
	print("final velocity: " + str(final_velocity))
	
	return final_velocity

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("player entered")
		print(body.velocity)
		body.velocity = _return_new_player_velocity(body.velocity)
		print(body.velocity)
		
