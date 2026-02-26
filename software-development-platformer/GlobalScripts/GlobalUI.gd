extends Node
#smoothly increases the size of the text when hovering
func growTween(button, xVar, yVar):
	button.pivot_offset = button.size/2
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(xVar,yVar), 0.1)
	
#smoothly decreases the size of the text when hovering
func shrinkTween(button):
	button.pivot_offset = button.size/2
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1,1), 0.1)

#saves the volume to be used in other scenes
func volume():
	var MasterVolume = get_node("/root/Menus/Settings/AudioSettings/MasterVolume/Volume").value()
	var EfffectsVolume = get_node("/root/Menus/Settings/AudioSettings/Effects/EffectsVolume").value()
	var MusicVolume = get_node("/root/Menus/Settings/AudioSettings/Music/MusicVolume").value()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), MasterVolume - 20)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), EfffectsVolume - 20)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), MusicVolume - 20)
