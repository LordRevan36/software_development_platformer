extends CanvasLayer
@onready var Buttons: Array = [
	$BoxContainer/VBoxContainer/Resume,
	$BoxContainer/VBoxContainer/Settings,
	$BoxContainer/VBoxContainer/MainMenu,
	$BoxContainer/VBoxContainer/Desktop
]


func _ready() -> void:
	for button in Buttons:
		_connect_button_signals(button)

func _connect_button_signals(button: Button):
	button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_button_mouse_exited.bind(button))

func _on_button_mouse_entered(button: Button) -> void:
	button.modulate = Color.YELLOW
	GlobalUI.growTween(button, 1.1, 1.1)

# Generic handler for mouse exit event
func _on_button_mouse_exited(button: Button) -> void:
	GlobalUI.shrinkTween(button) 
	button.modulate = Color.WHITE
	
func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Levels/MainMenu/Menus.tscn")
	
func _on_desktop_pressed() -> void:
	get_tree().quit()
