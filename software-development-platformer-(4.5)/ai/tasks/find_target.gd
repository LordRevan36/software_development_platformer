@tool
extends BTAction

@export var group: StringName
@export var target_node_var: StringName = &"target"
var target

func _tick(_delta: float) -> Status:
	if group == "Enemy":
		target = get_enemy_node()
	elif group == "Player":
		target = get_player_node()
	blackboard.set_var(target_node_var,target)
	return SUCCESS
func get_enemy_node():
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	if nodes.size() >= 2:
		while agent.check_for_self(nodes.front()): #pools every node, picks first one, checks to make sure it's not self
			nodes.shuffle() #shuffles it so self might no longer be at front
		return nodes.front()

func get_player_node():
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	return nodes[0]
