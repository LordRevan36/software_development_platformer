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
var HpLevel = 0
var ManaLevel = 0

func _ready() -> void:
	#iterates through the button group to connect the mouse entered and exited signals
	for button in get_tree().get_nodes_in_group("Buttons"):
		_connect_button_signals(button)
		if button not in get_tree().get_nodes_in_group("Start"):
			button.modulate = Color.DARK_GRAY
	
	#saves the states of the buttons so they stay the same when changing menus
	sync_button(Backflip, GlobalControls.canBackflip)
	sync_button(Frontflip, GlobalControls.canFrontflip)
	# Logic for tiered upgrades
	update_tier(AttackStep, AttackUpgrade2, AttackLevel >= 5, GlobalPlayer.can_continue_atk)
	update_tier(HealthStep, HealthUpgrade2, GlobalPlayer.MAX_Health >= 150, GlobalPlayer.can_continue_hp)
	update_tier(ManaStep, ManaUpgrade2, GlobalPlayer.MAX_Mana >= 150, GlobalPlayer.can_continue_mana)

func sync_button(btn: CanvasItem, condition: bool):
	btn.modulate = Color.GREEN if condition else Color.WHITE

func update_tier(step_btn, upgrade_btn, is_unlocked, is_complete):
	if is_unlocked: step_btn.modulate = Color.WHITE
	if is_complete:
		step_btn.modulate = Color.GREEN
		upgrade_btn.modulate = Color.WHITE


func _connect_button_signals(button: Button):
	button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_button_mouse_exited.bind(button))

func _process(_delta: float) -> void:
	AttackLevel = GlobalPlayer.Attack
	HpLevel = (GlobalPlayer.MAX_Health - 100)/10
	ManaLevel = (GlobalPlayer.MAX_Mana - 100)/10
	if Input.is_action_just_released("Skills") and can_close and not $PauseMenu.visible:
		get_tree().paused = false
		can_close = false
		hide()
	
	#can pause if in the skill tree
	if Input.is_action_just_released("Pause") and can_close:
		$PauseMenu.show()
	
	#checks the levels and changes the color based on the button level
	_level_up(AttackUpgrade1, AttackUpgrade2, AttackLevel, AtkUpgrades1, AtkUpgrades2)
	_level_up(HealthUpgrade1, HealthUpgrade2, HpLevel, HUP1, HUP2)
	_level_up(ManaUpgrade1, ManaUpgrade2, ManaLevel, ManaUp1, ManaUp2)
	
	$ColorRect/Title.text = ("Skill Points: " + str(GlobalPlayer.skill_points))
	$ColorRect/Title.position = Vector2(1220/2 - $ColorRect/Title.size.x/2, 40)
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
	if GlobalPlayer.Attack < 5 and GlobalPlayer.skill_points > 0:
		GlobalPlayer.Attack += 1
		GlobalPlayer.skill_points -= 1
	if GlobalPlayer.Attack == 5:
		AttackStep.modulate = Color.WHITE

func _on_attack_upgrade_2_pressed() -> void:
	if GlobalPlayer.can_continue_atk:
		if GlobalPlayer.Attack < 10 and GlobalPlayer.skill_points > 0:
			GlobalPlayer.Attack += 1
			GlobalPlayer.skill_points -= 1

#makes all the buttons grow and shrink with the respective tweens
func _on_button_mouse_entered(button: Button) -> void:
	GlobalUI.growTween(button, 1.1, 1.1)
func _on_button_mouse_exited(button: Button) -> void:
	GlobalUI.shrinkTween(button) 

#temp button for working tree, prevents getting upgrades before unlocking the previous ones
func _on_attack_step_pressed() -> void:
	if GlobalPlayer.Attack >= 5 and not GlobalPlayer.can_continue_atk and GlobalPlayer.skill_points > 0:
		AttackStep.modulate = Color.GREEN
		GlobalPlayer.can_continue_atk = true
		AttackUpgrade2.modulate = Color.WHITE
		GlobalPlayer.skill_points -= 1


func _on_health_upgrade_1_pressed() -> void:
	if GlobalPlayer.MAX_Health < 150 and GlobalPlayer.skill_points > 0:
		GlobalPlayer.MAX_Health += 10
		GlobalPlayer.health_changed.emit(GlobalPlayer.MAX_Health, GlobalPlayer.MAX_Health)
		GlobalPlayer.skill_points -= 1
	if GlobalPlayer.MAX_Health == 150:
		HealthStep.modulate = Color.WHITE
	GlobalPlayer.health = GlobalPlayer.MAX_Health
	if HealthUpgrade1.modulate != Color.GREEN:
		GlobalPlayer.health = GlobalPlayer.MAX_Health

func _on_health_step_pressed() -> void:
	if GlobalPlayer.MAX_Health >= 150 and not GlobalPlayer.can_continue_hp and GlobalPlayer.skill_points > 0:
		HealthStep.modulate = Color.GREEN
		GlobalPlayer.can_continue_hp = true
		HealthUpgrade2.modulate = Color.WHITE
		GlobalPlayer.skill_points -= 1

func _on_health_upgrade_2_pressed() -> void:
	if GlobalPlayer.MAX_Health < 200 and GlobalPlayer.can_continue_hp and GlobalPlayer.skill_points > 0:
		GlobalPlayer.MAX_Health += 10
		GlobalPlayer.health_changed.emit(GlobalPlayer.MAX_Health, GlobalPlayer.MAX_Health)
		GlobalPlayer.skill_points -= 1
	if HealthUpgrade2.modulate != Color.GREEN:
		GlobalPlayer.health = GlobalPlayer.MAX_Health

func _on_mana_upgrade_1_pressed() -> void:
	if GlobalPlayer.MAX_Mana < 150 and GlobalPlayer.skill_points > 0:
		GlobalPlayer.MAX_Mana += 10
		GlobalPlayer.mana_changed.emit(GlobalPlayer.MAX_Mana, GlobalPlayer.MAX_Mana, 0.15)
		GlobalPlayer.skill_points -= 1
	GlobalPlayer.mana = GlobalPlayer.MAX_Mana
	if GlobalPlayer.MAX_Mana == 150:
		ManaStep.modulate = Color.WHITE
	if ManaUpgrade1.modulate != Color.GREEN:
		GlobalPlayer.mana = GlobalPlayer.MAX_Mana

func _on_mana_step_pressed() -> void:
	if GlobalPlayer.MAX_Mana >= 150 and not GlobalPlayer.can_continue_mana and GlobalPlayer.skill_points > 0:
		ManaStep.modulate = Color.GREEN
		GlobalPlayer.can_continue_mana = true
		ManaUpgrade2.modulate = Color.WHITE
		GlobalPlayer.skill_points -= 1

func _on_mana_upgrade_2_pressed() -> void:
	if GlobalPlayer.MAX_Mana < 200 and GlobalPlayer.can_continue_mana and GlobalPlayer.skill_points > 0:
		GlobalPlayer.MAX_Mana += 10
		GlobalPlayer.skill_points -= 1
		GlobalPlayer.mana_changed.emit(GlobalPlayer.MAX_Mana, GlobalPlayer.MAX_Mana, 0.15)
	if ManaUpgrade2.modulate != Color.GREEN:
		GlobalPlayer.mana = GlobalPlayer.MAX_Mana

func _level_up(button1, button2, level, upgrade1, upgrade2) -> void:
	if level > 0:
		if level <= 5:
			upgrade1.texture = load("res://Assets/HUD/Upgrade%d.png" %level)
		if level >= 5:
			button1.modulate = Color.GREEN
			upgrade1.texture = load("res://Assets/HUD/Upgrade5.png")
		if level > 5:
			upgrade2.texture = load("res://Assets/HUD/Upgrade%d.png" % (level-5))
		if level == 10:
			button2.modulate = Color.GREEN
