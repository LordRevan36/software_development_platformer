@tool
extends Node2D

@onready var left_rope = $Ropes/LeftRope
@onready var right_rope = $Ropes/RightRope
@onready var child_platform = $Platform
@onready var collision_polygon_2d: CollisionPolygon2D = $Platform/CollisionPolygon2D
@onready var polygon_2d: Polygon2D = $Platform/Polygon2D

@export var radius : float = 300.0
@export var max_angle_degrees : float = 30.0
@export var swing_speed : float = 4.0
@export var phase_offset : float = 0.0
@export var currently_active : bool = true

@export var ropeTexture : Texture

@export var centerNode : bool = false
@export var updateLines : bool = false
@export var updateRadius: bool = false

var animation_player: AnimationPlayer
var animation: Animation

var time_passed : float = 0.0
var current_velocity : Vector2 = Vector2.ZERO
var _last_platform_global_pos : Vector2 = Vector2.ZERO

var testing
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player = $AnimationPlayer
	#animation_player.get_animation_library("").duplicate()
	animation = animation_player.get_animation("swing") #Makes animation library unique to this scene, to change properties through code.
	
	_update_lines()
	_update_plat_position()
	_setup_animation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Engine.is_editor_hint():
		if centerNode or updateRadius or updateLines:
			print("child platform position: ", child_platform.position.x, " , ", child_platform.position.y)
			print("swing position: ", " , ", position.x, position.y)
		if centerNode:
			_update_plat_position()
		if updateRadius:
			_update_radius()
		if updateLines:
			_update_lines()
	else:
		collision_polygon_2d.polygon = polygon_2d.polygon
		if currently_active:
			pass
			#_update_rotation(delta)
		#_save_velocity(delta)
	



func _update_plat_position() -> void:
	if Engine.is_editor_hint():
		print("Updating plat position")
		child_platform._center_node()
		child_platform.position = Vector2(0, radius)

func _update_radius() -> void:
	print("Updating radius")
	if Engine.is_editor_hint():
		radius = child_platform.position.y
		_update_plat_position()
		_update_lines()
	updateRadius = false

func _update_lines() -> void:
	print("Updating lines")
	var half_plat_size : Vector2 = child_platform.size_vector / 2
	child_platform._center_node()
	
	left_rope.position = Vector2.ZERO
	left_rope.points = PackedVector2Array()
	left_rope.add_point(Vector2.ZERO)
	#var left_end : Vector2 = child_platform.position + Vector2(-half_plat_size.x, -half_plat_size.y)
	var left_end : Vector2 = Vector2(0, radius) + Vector2(-half_plat_size.x, -half_plat_size.y)
	left_rope.add_point(left_end)
	
	right_rope.position = Vector2.ZERO
	right_rope.points = PackedVector2Array()
	right_rope.add_point(Vector2.ZERO)
	var right_end : Vector2 = Vector2(0, radius) + Vector2(half_plat_size.x, -half_plat_size.y)
	right_rope.add_point(right_end)
	
	left_rope.texture = ropeTexture
	right_rope.texture = ropeTexture
	
	updateLines = false

func _setup_animation() -> void:
	animation.length = swing_speed/2
	var ropes_index = animation.find_track("Ropes:rotation",0)
	animation.track_set_key_value(ropes_index, 0, -max_angle_degrees)
	animation.track_set_key_value(ropes_index, 1, max_angle_degrees)
	var posx_index = animation.find_track("Platform:position:x",0)
	animation.track_set_key_value(posx_index, 0, -cos(deg_to_rad(max_angle_degrees))*radius)
	animation.track_set_key_value(posx_index, 1, cos(deg_to_rad(max_angle_degrees))*radius)
	var posy_index = animation.find_track("Platform:position:y",0)
	animation.track_set_key_value(posy_index, 0, sin(deg_to_rad(max_angle_degrees))*radius)
	animation.track_set_key_value(posy_index, 1, radius)
	animation.track_set_key_value(posy_index, 2, sin(deg_to_rad(max_angle_degrees))*radius)
	var rot_index = animation.find_track("Platform:rotation",0)
	animation.track_set_key_value(rot_index, 0, -deg_to_rad(max_angle_degrees))
	animation.track_set_key_value(rot_index, 1, deg_to_rad(max_angle_degrees))
	print(max_angle_degrees)
#func _save_velocity(delta: float) -> void:
	#var current_global_pos = child_platform.global_position
	#current_velocity = (current_global_pos - _last_platform_global_pos) / delta
	#_last_platform_global_pos = current_global_pos
	#child_platform.constant_linear_velocity = current_velocity
#
#func _get_velocity() -> Vector2:
	#return current_velocity

#func _update_rotation(delta : float):
	#time_passed += delta
	#var sine_wave =  sin(time_passed * swing_speed + phase_offset)
	#var current_angle = sine_wave * deg_to_rad(max_angle_degrees)
	#rotation = current_angle
	#child_platform.position = Vector2(0, radius)
	#child_platform.rotation = 0
