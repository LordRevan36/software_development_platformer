extends ProgressBar
@onready var player := get_tree().get_first_node_in_group("Player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_value = player.MAX_Health
	value = player.health
	player.health_changed.connect(update_health)

var target_value := value

func update_health(current: int, max_h) -> void:
	max_value = max_h
	target_value = current

func _process(delta):
	value = lerp(value, target_value, delta * 8)
