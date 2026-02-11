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
	$AudioSettings/MasterVolume/VolumeLabel.text = "Master: " + str(int((value / 20) * 100)) + "%"
	if value == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value - 10)


func _on_effects_volume_value_changed(value: float) -> void:
	$AudioSettings/Effects/EffectsLabel.text = "Effects: " + str(int((value / 20) * 100)) + "%"
	if value == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Effects"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Effects"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), value - 10)


func _on_music_volume_value_changed(value: float) -> void:
	$AudioSettings/Music/MusicLabel.text = "Music: " + str(int((value / 20) * 100)) + "%"
	if value == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value - 10)
