extends StaticBody2D

@onready var polygon_2d = $Polygon2D
@onready var collision_polygon_2d = $CollisionPolygon2D

#func _set_values(pos, width, height):
	#position = pos;
	#width = width
	#height = height
	#$CollisionShape2D.position = pos
	#$CollisionShape2D.shape.size.x = width
	#$CollisionShape2D.shape.size.y = height
	#$Sprite2D.position = pos
	#$Sprite2D.scale.x = width/100
	#$Sprite2D.scale.y = height/100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_polygon_2d.polygon = polygon_2d.polygon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
