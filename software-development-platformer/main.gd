extends Node

@export var platform_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_platform_timer_timeout() -> void:
	var platform = platform_scene.instantiate()
	
	var xMin = 0
	var xRange = DisplayServer.window_get_size().x
	var xRandom = randi() % xRange + xMin
	var yMin = 0
	var yRange = DisplayServer.window_get_size().y
	var yRandom = randi() % yRange + yMin
	var pos: Vector2 = Vector2(xRandom, yRandom)
	
	platform._set_values(pos, 100, 50)
	
	$Platforms.add_child(platform)
	
