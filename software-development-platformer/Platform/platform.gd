extends StaticBody2D

@onready var polygon_2d = $Polygon2D
@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var border_line_2d = $BorderLine2D

@export var type : String = "rectangle"
@export var points : PackedVector2Array
@export var startPosition : Vector2
@export var sizeVector : Vector2 = Vector2(400,30)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#for rectangles, corners populated using top left corner and size (width/height)
	if (type.to_lower() == "rectangle"):
		points = PackedVector2Array()
		var topLeftCorner = startPosition
		var topRightCorner = Vector2(startPosition + Vector2(sizeVector.x, 0))
		var bottomRightCorner = Vector2(startPosition + sizeVector)
		var bottomLeftCorner = Vector2(startPosition + Vector2(0, sizeVector.y))
		points.push_back(topLeftCorner)
		points.push_back(topRightCorner)
		points.push_back(bottomRightCorner)
		points.push_back(bottomLeftCorner)
		polygon_2d.polygon = points
	#match other platform children to the polygon2D
	collision_polygon_2d.polygon = polygon_2d.polygon
	border_line_2d.points = points

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
