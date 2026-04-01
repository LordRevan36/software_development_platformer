extends Area2D

@onready var collision_shape = $CollisionShape2D
@onready var sprite_2d = $Sprite2D

@export var JUMP_MAXIMUM : float = 100000.0#set quite high bcuz we arent limiting it rn
@export var JUMP_MINIMUM : float = 750.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _return_new_player_velocity(p_velocity: Vector2) -> Vector2:
	var normal_vector : Vector2 = Vector2(0,1).rotated(rotation) #grab normal vector of platform
	var orthogonal_vector = normal_vector.orthogonal() #grab perpendicular vector for "project" later
	if normal_vector.y * p_velocity.y > 0: #if they were traveling down into the platform, make them travel up
		p_velocity.bounce(orthogonal_vector)
	var ortho_velocity : Vector2 = p_velocity.project(orthogonal_vector) #component of velocity traveling along platform
	var normal_velocity : Vector2 = p_velocity.project(normal_vector) #component of velocity traveling perpendicular to platform
	#normal_velocity *= JUMP_MULTIPLIER #scale perp. velocity with the jump boost multiplier of the bounce pad
	var normal_length = normal_velocity.length()
	normal_velocity = normal_velocity.normalized()
	normal_velocity *= -clamp(normal_length / sqrt(1.3), JUMP_MINIMUM, JUMP_MAXIMUM) #keep jump in range
	if normal_velocity.length() == 0:
		normal_velocity = normal_vector * JUMP_MINIMUM * -1
	var final_velocity = normal_velocity + ortho_velocity #add components back together
	return final_velocity
