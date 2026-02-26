extends Node2D

@onready var ControlsGrid: GridContainer = $ControlContainer/ControlsGrid
@onready var ReturnButton: Button = $ReturnButton
@onready var controls: Array
@onready var ChangeControl: Control = $ChangeControl
@onready var Buttons: Array = [
	$ControlContainer/ControlsGrid/Jump,
	$"ControlContainer/ControlsGrid/Move Down",
	$"ControlContainer/ControlsGrid/Move Left",
	$"ControlContainer/ControlsGrid/Move Right",
	$ControlContainer/ControlsGrid/Attack,
	$"ControlContainer/ControlsGrid/Flip Right",
	$"ControlContainer/ControlsGrid/Flip Left",
	$"ControlContainer/ControlsGrid/Skill Tree",
	$ControlContainer/ControlsGrid/Pause
]
#functions to get the input map and display what each input is
func _ready():
	for button in Buttons:
		_connect_button_signals(button)
	var i = 0
	for child_node in ControlsGrid.get_children():
		controls.append(child_node)
		child_node.pivot_offset = Vector2(child_node.size.x / 2, child_node.size.y / 2)
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue
		var event = (InputMap.action_get_events(action))[0].as_text()
		controls[i].text = controls[i].get_name() + ": " + event.substr(0, event.find(" "))
		i += 1

#Button Functions
func _connect_button_signals(button: Button):
	button.pressed.connect(_on_button_pressed.bind(button))
	button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_button_mouse_exited.bind(button))

# Generic handler for button presses
var buttonPressed
func _on_button_pressed(button: Button) -> void:
	buttonPressed = button.get_tooltip()
	ChangeControl.show()
	
func _input(event: InputEvent) -> void:
	if ChangeControl.visible:
		if event is InputEventKey and event.is_pressed():
			print(OS.get_keycode_string(event.keycode))
			print(buttonPressed)
			ChangeControl.hide()
		elif event is InputEventMouseButton and event.is_pressed():
			print(event.as_text())
			ChangeControl.hide()

func _on_button_mouse_entered(button: Button) -> void:
	button.modulate = Color.YELLOW
	GlobalUI.growTween(button, 1.1, 1.1)

# Generic handler for mouse exit event
func _on_button_mouse_exited(button: Button) -> void:
	GlobalUI.shrinkTween(button) 
	button.modulate = Color.WHITE

#Volume Functions
#Master Volume Settings
func _on_volume_value_changed(value: float) -> void:
	$AudioSettings/MasterVolume/VolumeLabel.text = "Master: " + str(int((value / 20) * 100)) + "%"
	if value == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value - 10)

#Effects Volume Settings
func _on_effects_volume_value_changed(value: float) -> void:
	$AudioSettings/Effects/EffectsLabel.text = "Effects: " + str(int((value / 20) * 100)) + "%"
	if value == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Effects"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Effects"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), value - 10)

#Music Volume Settings
func _on_music_volume_value_changed(value: float) -> void:
	$AudioSettings/Music/MusicLabel.text = "Music: " + str(int((value / 20) * 100)) + "%"
	if value == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value - 10)

func _on_return_button_mouse_entered() -> void:
	ReturnButton.modulate = Color.YELLOW
	GlobalUI.growTween(ReturnButton, 1.2, 1.2)

func _on_return_button_mouse_exited() -> void:
	ReturnButton.modulate = Color.WHITE
	GlobalUI.shrinkTween(ReturnButton)


func _on_return_button_pressed() -> void:
	hide()
	get_node("/root/Menus/MainMenu").show()
