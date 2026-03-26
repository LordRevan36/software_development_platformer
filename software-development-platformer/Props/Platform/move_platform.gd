@tool
extends Node2D
class_name move_platform

@onready var rope = $Rope
@onready var path = $Path
@onready var child_platform = $Platform
@onready var collision_polygon_2d: CollisionPolygon2D = $Platform/CollisionPolygon2D
@onready var polygon_2d: Polygon2D = $Platform/Polygon2D

@export var move_speed : float = 100
@export var ease_type = Tween.TRANS_LINEAR #0 > Linear, 1 > Sine, 2 > Quintic, 3 > Quartic, 4 > Quadratic, 5 > Exponential, and so on.
@export var loop_backwards : bool = false
@export var ropeTexture : Texture

@export var centerNode : bool = false
@export var updateLines : bool = false
@export var updateAnimation: bool = false
@export var toggleAnimation: bool = false


var tween = create_tween()

var time_passed : float = 0.0
var current_velocity : Vector2 = Vector2.ZERO
var _last_platform_global_pos : Vector2 = Vector2.ZERO

var testing
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	_update_lines()
	_update_plat_position()
	_setup_animation()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Engine.is_editor_hint():
		if centerNode or updateAnimation or updateLines or toggleAnimation:
			print("child platform position: ", child_platform.position.x, " , ", child_platform.position.y)
		if centerNode:
			_update_plat_position()
		if updateAnimation:
			_setup_animation()
		if updateLines:
			_update_lines()
		if toggleAnimation:
			_toggle_animation()


			#_update_rotation(delta)
		#_save_velocity(delta)
	



func _update_plat_position() -> void:
	child_platform.position = Vector2.ZERO
	centerNode = false
	#if Engine.is_editor_hint():
		#print("Updating plat position")
		#child_platform._center_node()
		#child_platform.position = Vector2(0, radius)


func _update_lines() -> void: #Puts the lines of the platform to the path of movement.
	var half_plat_size : Vector2 = child_platform.size_vector / 2
	
	#child_platform._center_node()
	#
	rope.position = Vector2.ZERO
	rope.points = PackedVector2Array()
	##var left_end : Vector2 = child_platform.position + Vector2(-half_plat_size.x, -half_plat_size.y)
	for point in path.get_point_count():
		rope.add_point(path.get_point_position(point))
	if !loop_backwards:
		rope.add_point(path.get_point_position(0))

	
	updateLines = false

func _setup_animation() -> void: #Fixes 
	tween.stop()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(ease_type)
	for point in path.get_point_count():
		var current_point = path.get_point_position(point)
		print(path.get_point_position(point))
		if point == 0:
			if loop_backwards:
				tween.tween_property(child_platform, "position", current_point, current_point.distance_to(path.get_point_position(point+1))/move_speed)
			else:
				print("Current: " + str(current_point))
				print("Next: " + str(path.get_point_position(path.get_point_count()-1)))
				print("DIstance: " + str(path.get_point_position(path.get_point_count()-1).distance_to(current_point)))
				tween.tween_property(child_platform, "position", current_point, path.get_point_position(path.get_point_count()-1).distance_to(current_point)/move_speed)
		else:
			tween.tween_property(child_platform, "position", current_point, path.get_point_position(point-1).distance_to(current_point)/move_speed)
	if loop_backwards:
		for point in range(path.get_point_count()-2,0,-1): #iterates back through the path, skipping endpoints
			var current_point = path.get_point_position(point)
			print(point)
			tween.tween_property(child_platform, "position", current_point, path.get_point_position(point+1).distance_to(path.get_point_position(point))/move_speed)
	tween.set_loops()

	tween.play()
	updateAnimation = false
	
func _toggle_animation() -> void:
	toggleAnimation = false
	if tween.is_running():
		tween.kill()
		centerNode = true
	else:
		updateAnimation = true
