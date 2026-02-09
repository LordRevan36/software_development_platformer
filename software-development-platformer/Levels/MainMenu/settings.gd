extends Node2D
@onready var ReturnButton: Button = $ReturnButton
	
func _on_return_button_pressed() -> void:
	hide()
	get_node("/root/Menus/MainMenu").show()

func _on_return_button_mouse_entered() -> void:
	ReturnButton.modulate = Color.YELLOW
	GlobalUI.growTween(ReturnButton)

func _on_return_button_mouse_exited() -> void:
	ReturnButton.modulate = Color.WHITE
	GlobalUI.shrinkTween(ReturnButton)

func _on_volume_value_changed(value: float) -> void:
	$VolumeLabel.text = "Volume: " + str(value)
	if value == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value - 15)
