@tool
extends StaticBody2D
class_name platform

#PROCESS TO CREATE A PLATFORM
#Instantiate a platform (do not copy-paste or duplicate, this will create a link between rectangles)
#Right-click and enable "editable children"
#For rectangles, use the rectangle outline to create your shape
	#Once you are done editing, use the center_kids feature of the parent node to align the platform node with its child geometry
#For polygons, they haven't been tested thoroughly so hold off on that

#TODO
#Update polygon mode

@onready var polygon_2d = $Polygon2D #visible inner portion of platform
@onready var collision_polygon_2d = $CollisionPolygon2D #collison portion
@onready var border_lines = $BorderLines #storage for each individually-generated border line
@onready var rectangle_outline = $RectangleOutline #rectangle handler to create rectangles easily

#enum to choose between rectangle and polygon mode
#RECTANGLE: will generate a rectangle with a handle that is easy to move, updates polygons to the shape of the rectangle
#POLYGON: (not done yet) allows you to create any shape but a little harder to work with
enum EditMode {RECTANGLE, POLYGON}
@export var edit_mode: EditMode = EditMode.RECTANGLE:
	set(value):
		edit_mode = value
		_update_editor_visibility()

#used only for polygon
@export var saved_polygon_points : PackedVector2Array

@export var size_vector : Vector2 = Vector2(400,40)
@export var texturePath : String = "res://.godot/imported/MissingTexture.png-22b33255012559b00bdd8aa9710640d6.ctex"
@export var textureWidth : float = 8 #width of texture imported
@export var enableSnap : bool = true #enables snapping to multiples of 0.5 texture width to ensure texture doesn't warp
@export var centerRectangle: bool = false #click true in editor to force the platform to center itself on the rectangle handler

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
	#set visibilities when running scene (hide editor handle)
	else:
		polygon_2d.visible = true
		border_lines.visible = true
		rectangle_outline.visible = false

func _snap_function() -> void:
	if not rectangle_outline or not collision_polygon_2d or not polygon_2d or not border_lines:
		return
	if not enableSnap:
		return
	if edit_mode == EditMode.RECTANGLE:
		#update position to be multiple of textureWidth/2
		var current_pos = rectangle_outline.position
		var new_pos = Vector2()
		new_pos.x = snapped(current_pos.x, textureWidth/2)
		new_pos.y = snapped(current_pos.y, textureWidth/2)
		if not new_pos.is_equal_approx(current_pos): #prevents the editor from freaking out as you drag stuff
			#push change to rectangle_outline
			rectangle_outline.position = new_pos
		#update size to be multiple of textureWidth/2
		var old_size = rectangle_outline.shape.size
		var new_size = Vector2()
		new_size.x = snapped(old_size.x, textureWidth/2)
		new_size.y = snapped(old_size.y, textureWidth/2)
		if not new_size.is_equal_approx(old_size): #prevents the editor from freaking out as you drag stuff
			#push change to rectangle_outline
			rectangle_outline.shape.size = new_size
			size_vector = new_size
	if edit_mode == EditMode.POLYGON:
		pass

func _sync_shapes() -> void:
	#stop if node deleted
	if not rectangle_outline or not collision_polygon_2d or not polygon_2d or not border_lines:
		return
	if edit_mode == EditMode.RECTANGLE:
		if centerRectangle:
			_center_node()
		#grab data from rectangle_outline
		size_vector = rectangle_outline.shape.size
		#match array to actual collision_polygon_2d, then push to other nodes
		collision_polygon_2d.polygon = _return_rectangle_points(rectangle_outline, size_vector)
		var adjusted_size_vector = size_vector - Vector2(textureWidth, textureWidth)
		polygon_2d.polygon = _return_rectangle_points(rectangle_outline, adjusted_size_vector)
		_generate_rectangle_borders(rectangle_outline, adjusted_size_vector)
	if edit_mode == EditMode.POLYGON:
		polygon_2d.polygon = collision_polygon_2d.polygon
		#generate polygon borders


func _generate_rectangle_borders(rectangle_handler, size) -> void:
	_clear_children(border_lines)
	var border_points = _return_rectangle_points(rectangle_handler, size)
	for i in border_points.size():
		var start_position = border_points.get(i)
		var end_position = border_points.get((i + 1) % border_points.size())
		var line_points = PackedVector2Array()
		line_points.push_back(Vector2())
		line_points.push_back(end_position - start_position)
		var line = Line2D.new()
		line.position = start_position
		line.points = line_points
		line.texture = load(texturePath)
		line.width = textureWidth
		line.texture_mode = Line2D.LINE_TEXTURE_TILE
		line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		border_lines.add_child(line)

func _center_node() -> void:
	if centerRectangle:
		if edit_mode == EditMode.RECTANGLE:
			#Move position transform to platform node
			global_position = rectangle_outline.global_position
			rectangle_outline.position = Vector2.ZERO
			rectangle_outline.force_update_transform()
			centerRectangle = false
			#collision_polygon_2d.position = Vector2.ZERO
			#polygon_2d.position = Vector2.ZERO
			#border_lines.position = Vector2.ZERO

#takes a center and size of a rectangle and returns an array of its corners
func _return_rectangle_points(rectangle_handler: Node2D, size_vector: Vector2) -> PackedVector2Array:
	var half_size = size_vector/2
	var local_corners = [
		Vector2(-half_size.x, -half_size.y),#top left
		Vector2(half_size.x, -half_size.y),#top right
		Vector2(half_size.x, half_size.y),#bottom right
		Vector2(-half_size.x, half_size.y)#bottom left
	]
	var handle_transform = rectangle_handler.transform #pulls transform changes such as rotation
	#push points to polygon array
	var pts = PackedVector2Array()
	for pt in local_corners:
		pts.push_back(handle_transform * pt) #note: handle_transform * pt != pt * handle_transform
	return pts

func _clear_children(parent_node) -> void: #clears children from a node (used to clear border_lines from border)
	for child in parent_node.get_children():
		child.queue_free()

func _is_rectangle_edit_mode() -> bool:
	return edit_mode == EditMode.RECTANGLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_sync_shapes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_snap_function()
		_sync_shapes()

#adding a comment to test
