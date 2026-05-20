extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var switch_timer: Timer = $SwitchTimer
var level_path

func _ready():
	GlobalControls.switch_scene.connect(switch_scene)

func switch_scene(lp: String) -> void:
	switch_timer.start()
	level_path = lp
	animation_player.play("switch_level")


func _on_switch_timer_timeout() -> void:
	get_node("level").get_child(0).queue_free()
	get_node("level").add_child(load(level_path).instantiate())
