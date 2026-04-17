@tool
extends Node2D

@onready var respawn: Marker2D = $Respawn

@export var update_kids: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if update_kids:
			_update_lines()

func _get_respawn() -> Vector2:
	return respawn.global_position

func _update_lines() -> void:
	var children = get_children()
	for child in children:
		if child is hazard:
			child.set_line_to_correct_width()
