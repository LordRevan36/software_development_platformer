extends Parallax2D
#really bad workaround script to try and fix major offest issues dealing with parallax
func _ready() -> void:
	for child in get_children():
		if child is ColorRect:
			print(child)
			print(child.position)
			child.position.x = (child.position.x - child.size.x/2) / scroll_scale.x
			child.position.y = (child.position.y - child.size.y/2) / scroll_scale.y
			print(child.position)
		else:
			print(child)
			print(child.position)
			child.position /= scroll_scale
			print(child.position)
	print("Parallax positions baked.")
