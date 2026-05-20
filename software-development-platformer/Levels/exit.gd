extends Node2D
class_name Exit

@export var level_path = ""
@export var target_exit = ""


func _ready():
	self.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	print("hey")
	if body.is_class("CharacterBody2D"):
		GlobalControls.emit_signal("switch_scene", level_path)
	#get_tree().root.get_node("main").switch_scene(level_path)
		print("Hey!")
	
