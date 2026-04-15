extends CanvasLayer
@onready var Backflip: Button = $ColorRect/Backflip
@onready var Frontflip: Button = $ColorRect/Frontflip
@onready var AttackUpgrade1: Button = $ColorRect/AttackUpgrades/AttackUpgrade1
@onready var AtkUpgrades1: TextureRect = $ColorRect/AttackUpgrades/AttackUpgrade1/AtkUpgrades1
@onready var AttackUpgrade2: Button = $ColorRect/AttackUpgrades/AttackUpgrade2
@onready var AtkUpgrades2: TextureRect = $ColorRect/AttackUpgrades/AttackUpgrade2/AtkUpgrades2
@onready var AttackStep: Button = $ColorRect/AttackUpgrades/AttackStep
@onready var HealthUpgrade1: Button = $ColorRect/HealthUpgrades/HealthUpgrade1
@onready var HUP1: TextureRect = $ColorRect/HealthUpgrades/HealthUpgrade1/HUP1
@onready var HealthStep: Button = $ColorRect/HealthUpgrades/HealthStep
@onready var HealthUpgrade2: Button = $ColorRect/HealthUpgrades/HealthUpgrade2
@onready var HUP2: TextureRect = $ColorRect/HealthUpgrades/HealthUpgrade2/HUP2
@onready var ManaUpgrade1: Button = $ColorRect/ManaUpgrades/ManaUpgrade1
@onready var ManaUp1: TextureRect = $ColorRect/ManaUpgrades/ManaUpgrade1/ManaUp1
@onready var ManaStep: Button = $ColorRect/ManaUpgrades/ManaStep
@onready var ManaUpgrade2: Button = $ColorRect/ManaUpgrades/ManaUpgrade2
@onready var ManaUp2: TextureRect = $ColorRect/ManaUpgrades/ManaUpgrade2/ManaUp2

#when true allows you to close the overlay with the same button used to open it
var can_close = false
var AttackLevel := GlobalPlayer.Attack

func _ready() -> void:
	#iterates through the button group to connect the mouse entered and exited signals
	for button in get_tree().get_nodes_in_group("Buttons"):
		_connect_button_signals(button)
		if button not in get_tree().get_nodes_in_group("Start"):
			button.modulate = Color.DARK_GRAY
	
	if AttackLevel >= 5:
		AttackStep.modulate = Color.WHITE
	if GlobalPlayer.can_continue_atk:
		AttackStep.modulate = Color.GREEN
		AttackUpgrade2.modulate = Color.WHITE
	if GlobalControls.canBackflip:
		Backflip.modulate = Color.GREEN
	if GlobalControls.canFrontflip:
		Frontflip.modulate = Color.GREEN

func _connect_button_signals(button: Button):
	button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_button_mouse_exited.bind(button))

func _process(_delta: float) -> void:
	AttackLevel = GlobalPlayer.Attack
	if Input.is_action_just_released("Skills") and can_close:
		get_tree().paused = false
		can_close = false
		hide()
		
	#checks the attack level and changes the color based on the button level
	if AttackLevel <= 5:
		AtkUpgrades1.texture = load("res://Assets/HUD/Upgrade%d.png" % AttackLevel)
	if AttackLevel >= 5:
		AttackUpgrade1.modulate = Color.GREEN
	if AttackLevel > 5:
		AtkUpgrades2.texture = load("res://Assets/HUD/Upgrade%d.png" % (AttackLevel-5))
	if AttackLevel == 10:
		AttackUpgrade2.modulate = Color.GREEN
		
	if GlobalPlayer.MAX_Health > 100 and GlobalPlayer.MAX_Health <= 150:
		HUP1.texture = load("res://Assets/HUD/Upgrade%d.png" % ((GlobalPlayer.MAX_Health - 100)/10))
	if GlobalPlayer.MAX_Health >= 150:
		HealthUpgrade1.modulate = Color.GREEN
	if GlobalPlayer.MAX_Health > 150:
		HUP2.texture = load("res://Assets/HUD/Upgrade%d.png" % ((GlobalPlayer.MAX_Health - 150)/10))
	if GlobalPlayer.MAX_Health == 200:
		HealthUpgrade2.modulate = Color.GREEN
		
	if GlobalPlayer.MAX_Mana > 100 and GlobalPlayer.MAX_Mana <= 150:
		ManaUp1.texture = load("res://Assets/HUD/Upgrade%d.png" % ((GlobalPlayer.MAX_Mana - 100)/10))
	if GlobalPlayer.MAX_Mana >= 150:
		ManaUpgrade1.modulate = Color.GREEN
	if GlobalPlayer.MAX_Mana > 150:
		ManaUp2.texture = load("res://Assets/HUD/Upgrade%d.png" % ((GlobalPlayer.MAX_Mana - 150)/10))
	if GlobalPlayer.MAX_Mana == 200:
		ManaUpgrade2.modulate = Color.GREEN
		

func _on_skill_timer_timeout() -> void:
	can_close = true

#changes the can flip variables to true to allow flipping
func _on_backflip_pressed() -> void:
	GlobalControls.canBackflip = true
	Backflip.modulate = Color.GREEN
func _on_frontflip_pressed() -> void:
	GlobalControls.canFrontflip = true
	Frontflip.modulate = Color.GREEN

#levels up the attack by increasing the player attack variable
func _on_attack_upgrades_pressed() -> void:
	if GlobalPlayer.Attack < 5:
		GlobalPlayer.Attack += 1
	print(GlobalPlayer.Attack)
	if GlobalPlayer.Attack == 5:
		AttackStep.modulate = Color.WHITE
func _on_attack_upgrade_2_pressed() -> void:
	if GlobalPlayer.can_continue_atk:
		if GlobalPlayer.Attack < 10:
			GlobalPlayer.Attack += 1
		print(GlobalPlayer.Attack)

#makes all the buttons grow and shrink with the respective tweens
func _on_button_mouse_entered(button: Button) -> void:
	GlobalUI.growTween(button, 1.1, 1.1)
func _on_button_mouse_exited(button: Button) -> void:
	GlobalUI.shrinkTween(button) 

#temp button for working tree, prevents getting upgrades before unlocking the previous ones
func _on_attack_step_pressed() -> void:
	if GlobalPlayer.Attack >= 5:
		AttackStep.modulate = Color.GREEN
		GlobalPlayer.can_continue_atk = true
		AttackUpgrade2.modulate = Color.WHITE


func _on_health_upgrade_1_pressed() -> void:
	if GlobalPlayer.MAX_Health < 150:
		GlobalPlayer.MAX_Health += 10
		GlobalPlayer.health_changed.emit(GlobalPlayer.MAX_Health, GlobalPlayer.MAX_Health)
		GlobalPlayer.health = GlobalPlayer.MAX_Health
	print(GlobalPlayer.MAX_Health)
	if GlobalPlayer.MAX_Health == 150:
		HealthStep.modulate = Color.WHITE

func _on_health_step_pressed() -> void:
	if GlobalPlayer.MAX_Health >= 150:
		HealthStep.modulate = Color.GREEN
		GlobalPlayer.can_continue_hp = true
		HealthUpgrade2.modulate = Color.WHITE

func _on_health_upgrade_2_pressed() -> void:
	if GlobalPlayer.MAX_Health < 200:
		GlobalPlayer.MAX_Health += 10
		GlobalPlayer.health_changed.emit(GlobalPlayer.MAX_Health, GlobalPlayer.MAX_Health)
		GlobalPlayer.health = GlobalPlayer.MAX_Health
	print(GlobalPlayer.MAX_Health)


func _on_mana_upgrade_1_pressed() -> void:
	if GlobalPlayer.MAX_Mana < 150:
		GlobalPlayer.MAX_Mana += 10
		GlobalPlayer.mana_changed.emit(GlobalPlayer.MAX_Mana, GlobalPlayer.MAX_Mana)
		GlobalPlayer.mana = GlobalPlayer.MAX_Mana
	print(GlobalPlayer.MAX_Mana)
	if GlobalPlayer.MAX_Mana == 150:
		ManaStep.modulate = Color.WHITE

func _on_mana_step_pressed() -> void:
	if GlobalPlayer.MAX_Mana >= 150:
		ManaStep.modulate = Color.GREEN
		GlobalPlayer.can_continue_mana = true
		ManaUpgrade2.modulate = Color.WHITE

func _on_mana_upgrade_2_pressed() -> void:
	if GlobalPlayer.MAX_Mana < 200:
		GlobalPlayer.MAX_Mana += 10
		GlobalPlayer.mana_changed.emit(GlobalPlayer.MAX_Mana, GlobalPlayer.MAX_Mana)
		GlobalPlayer.mana = GlobalPlayer.MAX_Mana
	print(GlobalPlayer.MAX_Mana)
