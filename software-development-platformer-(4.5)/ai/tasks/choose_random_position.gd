@tool
extends BTAction
#https://www.youtube.com/watch?v=gAk3xl5fBsM
#tutorial moment :P

@export var min_pos_range: float = 40.0
@export var max_pos_range: float = 100.0

@export var pos_var: StringName = &"pos" #like a global variable
@export var dir_var: StringName = &"dir"

func _tick(_delta: float) -> Status:
	var pos: Vector2
	var dir = random_dir()
	
	pos = random_pos(dir)
	blackboard.set_var(pos_var, pos)
	return SUCCESS
	
func random_pos(dir):
	var vector: Vector2
	var distance = randi_range(min_pos_range,max_pos_range) * dir
	var final_position = (distance + agent.global_position.x)
	vector.x = final_position
	return vector
	
func random_dir():
	var dir = randi_range(-2, 1)
	if abs(dir) != dir:
		dir = -1
	else:
		dir = 1
	blackboard.set_var(dir_var, dir)
	return dir
