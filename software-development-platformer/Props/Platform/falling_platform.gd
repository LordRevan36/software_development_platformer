@tool
extends "res://Props/Platform/platform.gd"

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
var shake_strength_min : float = 1
var shake_strength_max : float = 5
var shake_strength : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	GlobalPlayer.landed.connect(_try_to_start_falling)
	shake_timer.wait_time = shake_timer_length
	fall_timer.wait_time = fall_timer_length
	fall_timer.wait_time = fall_timer_length

func _try_to_start_falling(landingVelocity, collider) -> void:
	if collider == self:
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
		polygon_2d.position = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		border_lines.position = polygon_2d.position

func _start_fall() -> void:
	pass

func _fall_logic() -> void:
	match(state):
		State.PREFALL:
			_shake_before_fall()
		State.FALLING:
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	_fall_logic()

func _on_shake_timer_timeout() -> void:
	state = State.FALLING
	shake_strength = shake_strength_min
	
