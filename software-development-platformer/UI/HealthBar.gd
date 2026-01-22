extends TextureProgressBar
@onready var player := get_tree().get_first_node_in_group("Player")
var health_tween: Tween
@export var player_path: NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = player.MAX_Health
	value = player.health
	player.health_changed.connect(update_health)

func update_health(current: float, max_health: float):
	max_value = max_health
	health_tween = create_tween()
	health_tween.tween_property(
		self,
		"value",
		current,
		0.15
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
