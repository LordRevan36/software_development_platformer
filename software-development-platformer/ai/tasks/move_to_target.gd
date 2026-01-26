@tool
extends BTAction

@export var target_var := &"target"

@export var speed_var = 60
@export var tolerance = 20

func _tick(_delta: float) -> Status:
	var target = blackboard.get_var(target_var)
	if target != null:
		var target_pos = target.global_position
		var dir = agent.global_position.direction_to(target_pos)
		#assumes only x position. needs tweaking later
		
		if abs(agent.global_position.x - target_pos.x) < tolerance:
			agent.move(dir.x,0)
			return SUCCESS
		else:
			agent.move(dir.x, speed_var)
			return RUNNING
	return FAILURE
