@tool
extends Node2D

@onready var left_rope = $Ropes/LeftRope
@onready var right_rope = $Ropes/RightRope
@onready var child_platform = $Platform

@export var radius : float = 300.0
@export var max_angle_degrees : float = 30.0
@export var swing_speed : float = 2.0
@export var phase_offset : float = 0.0
@export var currently_active : bool = true

@export var ropeTexture : Texture

@export var centerNode : bool = false
@export var updateLines : bool = false
@export var updateRadius: bool = false

var time_passed : float = 0.0
var current_velocity : Vector2 = Vector2.ZERO
var _last_platform_global_pos : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_lines()
	_update_plat_position()

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
		if currently_active:
			pass
			#_update_rotation(delta)
		#_save_velocity(delta)
	



func _update_plat_position() -> void:
	child_platform._center_node()
	child_platform.position = Vector2(0, radius)

func _update_radius() -> void:
	if Engine.is_editor_hint():
		radius = child_platform.position.y
		_update_plat_position()
		_update_lines()
	updateRadius = false

func _update_lines() -> void:
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
