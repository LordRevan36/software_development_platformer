@tool
extends Line2D

#General tool script to assist level creation.

@export var assign_variables : bool = false
@export var sync_shapes : bool = false


var parent_node
var polygon_node
var collision_node


	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(true)
	parent_node = get_parent()
	assignVariables()
	if parent_node is StaticBody2D:
		createCollision()
	else:
		collision_node = null
	pass
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if parent_node == null:
			parent_node = get_parent()
		if assign_variables:
			assign_variables = false
			assignVariables()
		if sync_shapes:
			sync_shapes = false
			syncShapes()
			
func assignVariables():
	if !parent_node.has_node("Polygon2D"):
		polygon_node = Polygon2D.new()
		parent_node.add_child(polygon_node)
		polygon_node.name = "Polygon2D"
		if Engine.is_editor_hint():
			polygon_node.owner = get_tree().edited_scene_root
	else:
		polygon_node = parent_node.get_node("Polygon2D")
	polygon_node.scale = Vector2(4,4)

	self.texture_mode = Line2D.LINE_TEXTURE_TILE
	self.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	self.scale = Vector2(4,4)

	if parent_node is StaticBody2D:
		createCollision()

func syncShapes():
	polygon_node.polygon = self.points

	
	#polygon_node.append()
	if collision_node:
		collision_node.polygon = polygon_node.polygon
		collision_node.position.y = position.y + texture.get_height()
	polygon_node.position.y = position.y + texture.get_height()


func createCollision():
	if !parent_node.has_node("CollisionPolygon2D"):
		collision_node = CollisionPolygon2D.new()
		parent_node.add_child(collision_node)
		if Engine.is_editor_hint():
			collision_node.owner = get_tree().edited_scene_root
	else:
		collision_node = parent_node.get_node("CollisionPolygon2D")

	collision_node.name = "CollisionPolygon2D"
	collision_node.visible = false
	collision_node.scale = Vector2(4,4)
	
