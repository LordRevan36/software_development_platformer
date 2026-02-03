extends Node2D
@onready var StartButton: Button = $CenterContainer/StartButton
@onready var SettingsButton: Button = $CenterContainer2/SettingsButton

func _on_start_button_mouse_entered() -> void:
	StartButton.modulate = Color.YELLOW

func _on_start_button_mouse_exited() -> void:
	StartButton.modulate = Color.WHITE
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Forest/main.tscn")


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/MainMenu/Settings.tscn")


func _on_settings_button_mouse_entered() -> void:
	SettingsButton.modulate = Color.YELLOW


func _on_settings_button_mouse_exited() -> void:
	SettingsButton.modulate = Color.WHITE
