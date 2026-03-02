extends Camera2D
var lerp_speed = 0.97

@onready var player: CharacterBody2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.state == Player.State.ATTACK: #camera moves slower when attacking, fixes bug that let them move camera farther than intended
		offset = offset.move_toward(player.velocity/1.5+Vector2(0,-50), delta * 100)
	else:
		offset = offset.move_toward(player.velocity/1.5+Vector2(0,-50), delta * 100)
	#prevents camera from going out of bounds. BROKEN
	#offset.x = clamp(offset.x+player.position.x, limit_left, limit_right)-player.position.x
	#offset.y = clamp(offset.y+player.position.y, limit_top, limit_bottom)-player.position.y
