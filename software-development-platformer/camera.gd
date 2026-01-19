extends Camera2D
var lerp_speed = 0.97

@onready var player: CharacterBody2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.state == "attack": #camera moves slower when attacking, fixes bug that let them move camera farther than intended
		offset = offset.lerp(player.velocity/1.5+Vector2(0,-50), delta * lerp_speed/2)
	else:
		offset = offset.lerp(player.velocity/1.5+Vector2(0,-50), delta * lerp_speed)
