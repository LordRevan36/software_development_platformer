extends RigidBody2D

@onready var AnimSprite: AnimatedSprite2D = $AnimatedSprite2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


#detecting when player attacks
func _on_attackable_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		linear_velocity.x += -sign(Global.player_position.x-position.x)*100 + Global.player_velocity.x/4
		linear_velocity.y += -300
	
func move(dir, speed) -> void:
	linear_velocity.x = dir * speed
	updateAnimations(dir)
	
func updateAnimations(dir) -> void:
	if abs(dir)==dir:
		AnimSprite.flip_h = true
	else:
		AnimSprite.flip_h = false
