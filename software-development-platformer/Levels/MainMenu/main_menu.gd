extends Node2D
@onready var StartButton: Button = $StartButton
@onready var SettingsButton: Button = $SettingsButton
@onready var ExitButton: Button = $ExitButton

#Start Button functions
func _on_start_button_mouse_entered() -> void:
	StartButton.modulate = Color.YELLOW
	GlobalUI.growTween(StartButton)

func _on_start_button_mouse_exited() -> void:
	StartButton.modulate = Color.WHITE
	GlobalUI.shrinkTween(StartButton)
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Forest/main.tscn")


#Settings Button functions
func _on_settings_button_pressed() -> void:
	hide()
	get_node("/root/Menus/Settings").show()

func _on_settings_button_mouse_entered() -> void:
	SettingsButton.modulate = Color.YELLOW
	GlobalUI.growTween(SettingsButton)

func _on_settings_button_mouse_exited() -> void:
	SettingsButton.modulate = Color.WHITE
	GlobalUI.shrinkTween(SettingsButton)


#Exit Button functions
func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_exit_button_mouse_entered() -> void:
	ExitButton.modulate = Color.YELLOW
	GlobalUI.growTween(ExitButton)

func _on_exit_button_mouse_exited() -> void:
	ExitButton.modulate = Color.WHITE
	GlobalUI.shrinkTween(ExitButton)
