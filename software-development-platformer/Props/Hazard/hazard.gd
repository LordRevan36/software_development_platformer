@tool
extends Area2D
class_name hazard

@onready var collision_shape = $CollisionShape
@onready var line = $Line2D

@export var update_line : bool = false #allows editor to choose to ask the line to update to the correct width


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_line_to_correct_width()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if update_line: #update the line if the editor asks it to get updated
			set_line_to_correct_width()

#sets the line ends to matcht the collision shape so the texture lines up
func set_line_to_correct_width() -> void:
	var half_width = collision_shape.shape.size.x / 2
	var the_points = PackedVector2Array()
	the_points.push_back(Vector2(-half_width, 0))
	the_points.push_back(Vector2(half_width, 0))
	line.points = the_points
	update_line = false
