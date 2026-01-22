extends Button
@onready var player := get_tree().get_first_node_in_group("Player")


# Called when the node enters the scene tree for the first time.
func _pressed() -> void:
	player.heal(10)
