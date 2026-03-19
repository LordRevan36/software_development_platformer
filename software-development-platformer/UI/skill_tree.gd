extends CanvasLayer
@onready var Backflip: Button = $ColorRect/Backflip
@onready var Frontflip: Button = $ColorRect/Frontflip
@onready var AttackLevel: Button = $ColorRect/AttackUpgrades
var can_close = false

func _process(_delta: float) -> void:
	if GlobalControls.canBackflip:
		Backflip.modulate = Color.GREEN
	if GlobalControls.canFrontflip:
		Frontflip.modulate = Color.GREEN
	
	if Input.is_action_just_released("Skills") and can_close:
		get_tree().paused = false
		can_close = false
		hide()
		
	if GlobalPlayer.Attack == 1:
		AttackLevel.icon = preload("res://Assets/HUD/Upgrade1.png")
	elif GlobalPlayer.Attack == 2:
		AttackLevel.icon = preload("res://Assets/HUD/Upgrade2.png")
	elif GlobalPlayer.Attack == 3:
		AttackLevel.icon = preload("res://Assets/HUD/Upgrade3.png")
	elif GlobalPlayer.Attack == 4:
		AttackLevel.icon = preload("res://Assets/HUD/Upgrade4.png")
	elif GlobalPlayer.Attack == 5:
		AttackLevel.icon = preload("res://Assets/HUD/Upgrade5.png")
		AttackLevel.modulate = Color.GREEN

func _on_backflip_pressed() -> void:
	GlobalControls.canBackflip = true
	
func _on_backflip_mouse_entered() -> void:
	GlobalUI.growTween(Backflip, 1.1, 1.1)


func _on_backflip_mouse_exited() -> void:
	GlobalUI.shrinkTween(Backflip)


func _on_skill_timer_timeout() -> void:
	can_close = true


func _on_frontflip_pressed() -> void:
	GlobalControls.canFrontflip = true


func _on_frontflip_mouse_entered() -> void:
	GlobalUI.growTween(Frontflip, 1.1, 1.1)

func _on_frontflip_mouse_exited() -> void:
	GlobalUI.shrinkTween(Frontflip)


func _on_attack_upgrades_pressed() -> void:
	if GlobalPlayer.Attack < 5:
		GlobalPlayer.Attack += 1


func _on_attack_upgrades_mouse_entered() -> void:
	GlobalUI.growTween(AttackLevel, 1.1, 1.1)


func _on_attack_upgrades_mouse_exited() -> void:
	GlobalUI.shrinkTween(AttackLevel)
