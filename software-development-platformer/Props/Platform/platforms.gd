@tool
extends Node2D

#script for platforms container to allow you to update all children simultaneously

@export var center_kids : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _center_child_nodes() -> void:
	if center_kids:
		var children = get_children()
		for child in children:
			if child is platform and child._is_rectangle_edit_mode():
				child.centerRectangle = true
			elif child is fall_platform:
				if child.child_platform._is_rectangle_edit_mode():
					child.child_platform.centerRectangle = true
				await get_tree().create_timer(0.5).timeout
				child.centerNode = true
			elif child is move_platform:
				if child.child_platform._is_rectangle_edit_mode():
					child.child_platform.centerRectangle = true
				await get_tree().create_timer(0.5).timeout
				child.centerNode = true
		center_kids = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Engine.is_editor_hint()):
		_center_child_nodes()
