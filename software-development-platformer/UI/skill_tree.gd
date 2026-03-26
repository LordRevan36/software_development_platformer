extends CanvasLayer
@onready var Backflip: Button = $ColorRect/Backflip
@onready var Frontflip: Button = $ColorRect/Frontflip
@onready var AttackUpgrade1: Button = $ColorRect/AttackUpgrade1
@onready var AtkUpgrades1: TextureRect = $ColorRect/AttackUpgrade1/AtkUpgrades1
@onready var AttackUpgrade2: Button = $ColorRect/AttackUpgrade2
@onready var AtkUpgrades2: TextureRect = $ColorRect/AttackUpgrade2/AtkUpgrades2
@onready var TestStep: Button = $ColorRect/TestStep
#when true allows you to close the overlay with the same button used to open it
var can_close = false
var can_continue

func _ready() -> void:
	#iterates through the button group to connect the mouse entered and exited signals
	for button in get_tree().get_nodes_in_group("Buttons"):
		_connect_button_signals(button)
	TestStep.modulate = Color.DARK_GRAY
	AttackUpgrade2.modulate = Color.DARK_GRAY

func _connect_button_signals(button: Button):
	button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_button_mouse_exited.bind(button))

func _process(_delta: float) -> void:
	var AttackLevel := GlobalPlayer.Attack
	
	if Input.is_action_just_released("Skills") and can_close:
		get_tree().paused = false
		can_close = false
		hide()
	
	if AttackLevel <= 5:
		AtkUpgrades1.texture = load("res://Assets/HUD/Upgrade%d.png" % AttackLevel)
	if AttackLevel == 5:
		AttackUpgrade1.modulate = Color.GREEN
	if AttackLevel > 5:
		AtkUpgrades2.texture = load("res://Assets/HUD/Upgrade%d.png" % (AttackLevel-5))
	if AttackLevel == 10:
		AttackUpgrade2.modulate = Color.GREEN
		

func _on_skill_timer_timeout() -> void:
	can_close = true

func _on_backflip_pressed() -> void:
	GlobalControls.canBackflip = true
	Backflip.modulate = Color.GREEN

func _on_frontflip_pressed() -> void:
	GlobalControls.canFrontflip = true
	Frontflip.modulate = Color.GREEN

func _on_attack_upgrades_pressed() -> void:
	if GlobalPlayer.Attack < 5:
		GlobalPlayer.Attack += 1
	print(GlobalPlayer.Attack)
	if GlobalPlayer.Attack == 5:
		TestStep.modulate = Color.WHITE

func _on_button_mouse_entered(button: Button) -> void:
	GlobalUI.growTween(button, 1.1, 1.1)


func _on_button_mouse_exited(button: Button) -> void:
	GlobalUI.shrinkTween(button) 

#temp button for working tree, prevents getting upgrades before unlocking the previous ones
func _on_test_step_pressed() -> void:
	if GlobalPlayer.Attack >= 5:
		TestStep.modulate = Color.GREEN
		can_continue = true
		AttackUpgrade2.modulate = Color.WHITE

func _on_attack_upgrade_2_pressed() -> void:
	if can_continue:
		if GlobalPlayer.Attack < 10:
			GlobalPlayer.Attack += 1
		print(GlobalPlayer.Attack)
