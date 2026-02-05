extends "res://Props/Platform/platform.gd"

@onready var fall_timer = $FallTimer
@onready var regen_timer = $RegenTimer

@export var fall_timer_length : float = 1
@export var regen_timer_length : float = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
