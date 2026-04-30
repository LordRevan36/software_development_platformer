extends Node2D
@onready var ControlsGrid: GridContainer = $ControlContainer/ControlsGrid
@onready var ReturnButton: Button = $ReturnButton
@onready var controls: Array
@onready var ChangeControl: Control = $ChangeControl
@onready var ControlPicker: Label = $ChangeControl/ColorRect2/ControlPicker
@onready var YesButton: Button = $ChangeControl/ColorRect2/ControlUsed/YesButton
@onready var NoButton: Button = $ChangeControl/ColorRect2/ControlUsed/NoButton
@onready var ControlUsed: Control = $ChangeControl/ColorRect2/ControlUsed
@onready var Buttons: Array = [
	$ControlContainer/ControlsGrid/Jump,
	$"ControlContainer/ControlsGrid/Move Down",
	$"ControlContainer/ControlsGrid/Move Left",
	$"ControlContainer/ControlsGrid/Move Right",
	$ControlContainer/ControlsGrid/Attack,
	$ControlContainer/ControlsGrid/Frontflip,
	$ControlContainer/ControlsGrid/Backflip,
	$"ControlContainer/ControlsGrid/Skill Tree",
	$ControlContainer/ControlsGrid/Pause,
	$ControlContainer/ControlsGrid/Dodgeball
]
@onready var uiActions: Array

#functions to get the input map and display what each input is
func _ready() -> void:
	for button in Buttons:
		_connect_button_signals(button)
	for action in InputMap.get_actions():
		if not action.begins_with("ui_"):
			continue

func _process(_delta: float) -> void:
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
var key
var buttonPressed
var agree
var decided
var pending_event: InputEvent = null
func _on_button_pressed(button: Button) -> void:
	buttonPressed = button.get_tooltip()
	ChangeControl.show()
	ControlPicker.text = "Select control for " + button.get_name()

func _on_yes_button_pressed() -> void:
	InputMap.action_erase_events(buttonPressed)
	InputMap.action_add_event(buttonPressed, key)
	ControlUsed.hide()
	ChangeControl.hide()

func _on_no_button_pressed() -> void:
	ControlUsed.hide()
	ChangeControl.hide()

#input listener for changing controls
func _input(event: InputEvent) -> void:
	if ChangeControl.visible:
		if is_key_mapped(event) and not event.is_echo():
			ControlUsed.show()
			key = event
		elif (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed() and buttonPressed and not ControlUsed.visible:
			print(event.as_text())
			print(buttonPressed)
			InputMap.action_erase_events(buttonPressed)
			InputMap.action_add_event(buttonPressed, event)
			ChangeControl.hide()
			ControlUsed.hide()

func is_key_mapped(event: InputEvent) -> bool:
	# Iterate through all action names defined in the Project Settings -> Input Map
	for action_name in InputMap.get_actions():
		if action_name.begins_with("ui_"):
			continue
		# Get all InputEvents associated with the current action
		var events: Array = InputMap.action_get_events(action_name)
		for action_event in events:
			# Check if the event in the InputMap matches the one we are querying
			# You may need to compare relevant properties like scancode, device, etc.
			# A simple comparison might work for basic keys.
			if action_event.is_match(event):
				return true
	return false


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

func _on_yes_button_mouse_entered() -> void:
	YesButton.modulate = Color.YELLOW
	GlobalUI.growTween(YesButton, 1.2, 1.2)
	
func _on_yes_button_mouse_exited() -> void:
	YesButton.modulate = Color.WHITE
	GlobalUI.shrinkTween(YesButton)
	
func _on_no_button_mouse_entered() -> void:
	NoButton.modulate = Color.YELLOW
	GlobalUI.growTween(NoButton, 1.2, 1.2)
	
func _on_no_button_mouse_exited() -> void:
	NoButton.modulate = Color.WHITE
	GlobalUI.shrinkTween(NoButton)

func _on_return_button_pressed() -> void:
	hide()
	get_node("/root/Menus/MainMenu").show()
