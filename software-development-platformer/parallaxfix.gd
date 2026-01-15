extends Parallax2D
#really bad workaround script to try and fix major offest issues dealing with parallax
func _ready() -> void:
	for child in get_children():
		print(child.position)
		print(child)
		child.position *= scroll_scale.x
		print(child.position)
	print("Parallax positions baked.")
