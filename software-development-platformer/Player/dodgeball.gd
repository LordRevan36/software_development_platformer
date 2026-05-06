extends Area2D
@onready var Sprite: Sprite2D = $Sprite2D

var speed = 800
var direction = Vector2.ZERO

func _physics_process(delta: float) -> void:
	#only works if direction exists
	position.x += direction * speed * delta
	if direction < 0:
		Sprite.flip_h = true
	else:
		Sprite.flip_h = false

func _ready() -> void:
	await get_tree().create_timer(0.75).timeout
	queue_free()
