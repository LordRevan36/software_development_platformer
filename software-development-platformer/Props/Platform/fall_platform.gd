@tool
extends Node2D
class_name fall_platform

@onready var child_platform = $Platform
@onready var shake_timer = $ShakeTimer
@onready var fall_timer = $FallTimer
@onready var regen_timer = $RegenTimer
@onready var line_path = $LinePath

enum State {IDLE, PREFALL, FALLING, RESET}
@export var state: State = State.IDLE:
	set(value):
		state = value
		#can add function here

@export var shake_timer_length : float = 1.5
@export var fall_timer_length : float = 2
@export var regen_timer_length : float = 5
@export var centerNode: bool = false #click true in editor to force the platform to center itself on the rectangle handler

var shake_strength_min : float = 1
var shake_strength_max : float = 5
var shake_strength : float
const GRAVITY : float = 9.80
var destination : Vector2
var speed : float = 0.0
var path_vector : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#child_platform._sync_shapes()
	GlobalPlayer.landed.connect(_try_to_start_falling)
	shake_timer.wait_time = shake_timer_length
	fall_timer.wait_time = fall_timer_length
	regen_timer.wait_time = regen_timer_length
	destination = line_path.to_global(line_path.points[1])
	#vector from global start of line to global end (destination)
	path_vector = line_path.to_global(line_path.points[0]).direction_to(destination)
	if centerNode:
		_center_node()

func _try_to_start_falling(landingVelocity, collider) -> void:
	if collider == child_platform:
		_start_falling()

func _start_falling() -> void:
	shake_timer.start()
	state = State.PREFALL

	shake_strength = shake_strength_min
	var shake_tween = create_tween()
	shake_tween.tween_property(
		self,
		"shake_strength",
		shake_strength_max,
		shake_timer.wait_time
		).set_ease(Tween.EASE_IN)

func _shake_before_fall() -> void:
	if shake_strength > 0:
		child_platform.polygon_2d.position = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		child_platform.border_lines.position = child_platform.polygon_2d.position

func _fall_along_path(delta: float) -> void:
	speed += GRAVITY
	var fall_step = path_vector * speed * delta
	if child_platform.position.distance_to(destination) <= fall_step.length():
		child_platform.position = destination
		state = State.RESET
	else:
		child_platform.position += fall_step
	if child_platform.position == destination:
		state = State.RESET

func _fall_logic(delta: float) -> void:
	match(state):
		State.PREFALL:
			_shake_before_fall()
		State.FALLING:
			_fall_along_path(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#super(delta)
	if Engine.is_editor_hint():
		if centerNode:
			_center_node()
	_fall_logic(delta)

func _on_shake_timer_timeout() -> void:
	state = State.FALLING
	shake_strength = shake_strength_min
	child_platform.polygon_2d.position = Vector2.ZERO
	child_platform.border_lines.position = child_platform.polygon_2d.position
	speed = 0.0

func _center_node() -> void:
	#Move position transform to platform node
	global_position = child_platform.rectangle_outline.global_position
	child_platform.position = Vector2.ZERO
	child_platform.force_update_transform()
	centerNode = false
