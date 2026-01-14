extends Camera2D
var lerp_speed = 0.95

@onready var player: CharacterBody2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	offset = offset.lerp(player.velocity+Vector2(0,-50), delta * lerp_speed)
