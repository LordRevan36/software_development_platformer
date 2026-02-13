@tool
extends "res://Props/Platform/platform.gd"

@onready var fall_timer = $FallTimer
@onready var regen_timer = $RegenTimer

enum State {IDLE, PREFALL, FALLING, RESET}
@export var state: State = State.IDLE:
	set(value):
		state = value
		#can add function here

@export var fall_timer_length : float = 1
@export var regen_timer_length : float = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	GlobalPlayer.landed.connect(_try_to_start_falling)

func _try_to_start_falling(landingVelocity, collider) -> void:
	if collider == self:
		_start_falling()
	
func _start_falling() -> void:
	fall_timer.start()
	state = State.PREFALL

func _shake_before_fall() -> void:
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
