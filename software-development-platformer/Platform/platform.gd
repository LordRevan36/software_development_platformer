@tool
extends StaticBody2D

#PROCESS TO CREATE A PLATFORM
#Instantiate a platform (do not copy-paste or duplicate, this will create a link between rectangles)
#Right-click and enable "editable children"
#For rectangles, use the rectangle outline to create your shape
#For polygons, they haven't been tested thoroughly so hold off on that

#TODO
#Fix Line2D centering
#Update polygon mode

@onready var polygon_2d = $Polygon2D
@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var border_line_2d = $BorderLine2D
@onready var rectangle_outline = $RectangleOutline

enum EditMode {RECTANGLE, POLYGON}
@export var edit_mode: EditMode = EditMode.RECTANGLE:
	set(value):
		edit_mode = value
		_update_editor_visibility()
@export var points : PackedVector2Array
@export var startPosition : Vector2
@export var sizeVector : Vector2 = Vector2(400,50)

func _update_editor_visibility() -> void:
	if not collision_polygon_2d or not rectangle_outline:
		return
	#shows only the collision box used for that type of shape based on edit_mode
	if Engine.is_editor_hint():
		match edit_mode:
			EditMode.RECTANGLE:
				collision_polygon_2d.visible = false
				rectangle_outline.visible = true
			EditMode.POLYGON:
				collision_polygon_2d.visible = true
				rectangle_outline.visible = false
	else:
		polygon_2d.visible = true
		border_line_2d.visible = true
		rectangle_outline.visible = false

func _sync_shapes() -> void:
	#stop if node deleted
	if not rectangle_outline or not collision_polygon_2d or not polygon_2d or not border_line_2d:
		return
	if edit_mode == EditMode.RECTANGLE:
		#grab data from rectangle_outline
		var center = rectangle_outline.position
		sizeVector = rectangle_outline.shape.size
		var topLeftCorner = center - sizeVector/2
		var topRightCorner = Vector2(center + Vector2(sizeVector.x/2, -sizeVector.y/2))
		var bottomRightCorner = center + sizeVector/2
		var bottomLeftCorner = Vector2(center + Vector2(-sizeVector.x/2, sizeVector.y/2))
		#push points to polygon array
		points = PackedVector2Array()
		points.push_back(topLeftCorner)
		points.push_back(topRightCorner)
		points.push_back(bottomRightCorner)
		points.push_back(bottomLeftCorner)
		#match array to actual collision_polygon_2d, then push to other nodes
		collision_polygon_2d.polygon = points
		polygon_2d.polygon = points
		border_line_2d.points = points
	if edit_mode == EditMode.POLYGON:
		polygon_2d.polygon = collision_polygon_2d.polygon
		border_line_2d.points = collision_polygon_2d.polygon
		#border_line_2d.points = points


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_sync_shapes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_sync_shapes()
