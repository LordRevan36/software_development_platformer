extends Node
@onready var Up = InputMap.action_get_events("Up")
@onready var Down = InputMap.action_get_events("Down")
@onready var Right = InputMap.action_get_events("Right")
@onready var Left = InputMap.action_get_events("Left")
@onready var Attack = InputMap.action_get_events("Attack")
@onready var Frontflip = InputMap.action_get_events("Frontflip")
@onready var Backflip = InputMap.action_get_events("Backflip")
@onready var Skills = InputMap.action_get_events("Skills")
@onready var Pause = InputMap.action_get_events("Pause")

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
