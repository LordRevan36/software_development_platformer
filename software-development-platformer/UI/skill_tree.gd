extends CanvasLayer
@onready var Backflip: Button = $ColorRect/HBoxContainer/Backflip
@onready var Frontflip: Button = $ColorRect/HBoxContainer/Frontflip
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
