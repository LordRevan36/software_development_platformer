extends Node2D
@onready var ReturnButton: Button = $ReturnButton

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/MainMenu/MainMenu.tscn")

func _on_return_button_mouse_entered() -> void:
	ReturnButton.modulate = Color.YELLOW
	GlobalUI.growTween(ReturnButton)

func _on_return_button_mouse_exited() -> void:
	ReturnButton.modulate = Color.WHITE
	GlobalUI.shrinkTween(ReturnButton)
