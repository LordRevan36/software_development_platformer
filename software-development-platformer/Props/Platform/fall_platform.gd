@tool
extends Node2D
class_name fall_platform

@onready var child_platform = $Platform
@onready var shake_timer = $ShakeTimer
@onready var fall_timer = $FallTimer
@onready var regen_timer = $RegenTimer

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#child_platform._sync_shapes()
	GlobalPlayer.landed.connect(_try_to_start_falling)
	shake_timer.wait_time = shake_timer_length
	fall_timer.wait_time = fall_timer_length
	regen_timer.wait_time = regen_timer_length
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

func _start_downward_fall() -> void:
	pass

func _fall_logic() -> void:
	match(state):
		State.PREFALL:
			_shake_before_fall()
		State.FALLING:
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#super(delta)
	_fall_logic()

func _on_shake_timer_timeout() -> void:
	state = State.FALLING
	shake_strength = shake_strength_min
	

func _center_node() -> void:
	#Move position transform to platform node
	global_position = child_platform.rectangle_outline.global_position
	child_platform.position = Vector2.ZERO
	child_platform.force_update_transform()
	centerNode = false
