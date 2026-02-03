extends RigidBody2D

@onready var AnimSprite: AnimatedSprite2D = $AnimatedSprite2D
##behavior
##https://limboai.readthedocs.io/en/stable/hierarchical-state-machines/create-hsm.html
#@onready var hsm: LimboHSM = $LimboHSM
#@onready var idle_state: LimboState = $LimboHSM/IdleState
#@onready var move_state: LimboState = $LimboHSM/MoveState
#
#
#func _ready() -> void:
	#_init_state_machine()
#
#
#func _init_state_machine() -> void:
	#hsm.add_transition(idle_state, move_state, idle_state.EVENT_FINISHED)
	#hsm.add_transition(move_state, idle_state, move_state.EVENT_FINISHED)
#
	#hsm.initialize(self)
	#hsm.set_active(true)






# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


#detecting when player attacks
func _on_attackable_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		linear_velocity.x += -sign(Global.player_position.x-position.x)*100 + Global.player_velocity.x/4
		linear_velocity.y += -300
	
func move(dir, speed) -> void:
	linear_velocity.x = dir * speed
	updateAnimations(dir)
	
func updateAnimations(dir) -> void:
	if abs(dir)==dir:
		AnimSprite.flip_h = true
	else:
		AnimSprite.flip_h = false
		
func check_for_self(node): #for enemy ai
	if node == self:
		return true
	else:
		return false
func attackPlayer():
	linear_velocity.x = 20
	linear_velocity.y = -20
	
