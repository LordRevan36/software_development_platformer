extends Camera2D
var lerp_speed = 0.97
var cameraDirection: float = 0 #for looking up/down
@onready var player: CharacterBody2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("Down"): #dont have for looking up because rn, thats for jumping
		cameraDirection = 1
	else:
		cameraDirection = 0
	if player.state == "attack": #camera moves slower when attacking, fixes bug that let them move camera farther than intended
		offset = offset.lerp(player.velocity/1.5+Vector2(0,-50), delta * lerp_speed/2)
	else:
		offset = offset.lerp(player.velocity/1.5+Vector2(0,-50), delta * lerp_speed)
	#prevents camera from going out of bounds. BROKEN
	offset.y = move_toward(offset.y, offset.y + 600 * cameraDirection, delta * 200)
	offset.x = clamp(offset.x+player.position.x, limit_left, limit_right)-player.position.x
	offset.y = clamp(offset.y+player.position.y, limit_top, limit_bottom)-player.position.y
